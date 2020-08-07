
import Foundation
import Contentful
import DeepLinkKit

/// `StatefulContentfulClientProvider` is a type that this app uses to manage state related to Contentful such as which locale
/// should be specified in API requests, and which API should be used: preview or delivery. It also adds some additional
/// methods for "diff'ing" the results from the preview and delivery APIs so that the states of resources can be inferred.
final class StatefulContentfulClientProvider {

    /// The state machine that the app will use to observe state changes and execute relevant updates.
    public let stateMachine: StateMachine<StatefulContentfulClientProvider.State>

    let clientProvider: ContentfulClientProvider

    /// The client used to pull data from the Content Delivery API.
    var deliveryClient: Client {
        clientProvider.deliveryClient
    }

    /// The client used to pull data from the Content Preview API.
    var previewClient: Client {
        clientProvider.previewClient
    }

    let session: Session
    let credentials: ContentfulCredentials

    init(session: Session, credentials: ContentfulCredentials, state: State) {
        self.session = session
        self.credentials = credentials
        self.clientProvider = ContentfulClientProvider(credentials: credentials)
        self.stateMachine = StateMachine<State>(initialState: state)
    }

    /// A method to change the state of the receiving service to enable/disable editorial features.
    ///
    /// - Parameter shouldEnable: A boolean describing if editorial features should be enabled. `true` will enable editorial features.
    public func enableEditorialFeatures(_ shouldEnable: Bool) {
        session.persistEditorialFeatureState(isOn: shouldEnable)
        stateMachine.state.editorialFeaturesEnabled = shouldEnable
    }

    public func setLocale(_ locale: Contentful.Locale) {
        session.persistLocale(locale)
        stateMachine.state.locale = locale
    }

    public func setAPI(_ api: StatefulContentfulClientProvider.State.API) {
        session.persistAPI(api)
        stateMachine.state.api = api
    }


    /// A computed variable describing if views for Contentful resources should render state labels.
    public var shouldShowResourceStateLabels: Bool {
        return editorialFeaturesAreEnabled && stateMachine.state.api == .preview
    }

    /// Returns true if editorial features are enabled.
    public var editorialFeaturesAreEnabled: Bool {
        return stateMachine.state.editorialFeaturesEnabled
    }

    /// The available locales for the connected Contentful space. If there is an issue connecting to
    /// Contentful, a default array will be returned containing en-US and de-DE.
    public var locales: [Contentful.Locale] {
        let semaphore = DispatchSemaphore(value: 0)

        var locales = [Contentful.Locale]()

        client.fetchLocales { result in
            switch result {
            case .success(let response):
                locales = response.items
            case .failure:
                locales = [.americanEnglish(), .german()]
            }

            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return locales
    }

    /// The locale code of the currently selected locale.
    var currentLocaleCode: LocaleCode {
        return stateMachine.state.locale.code
    }


    /// If the receiving ContentfulService is in a state in which resource states should be resolved and
    /// rendered in the relevant views, this method will return `true` and trigger the logic to resolve said resource states.
    ///
    /// - Parameters:
    ///   - resource: The resource for which the state determination is being made.
    ///   - completion: A completion handler returning a stateful preview API resource.
    /// - Returns: A boolean value indicating if the state resolution logic will be executed.
    @discardableResult public func willResolveStateIfNecessary<T>(for resource: T,
                                                                  then completion: @escaping (Result<T, Error>, T?) -> Void) -> Bool
        where T: FieldKeysQueryable & EntryDecodable & Resource & StatefulResource {

        switch stateMachine.state.api {

        case .preview where stateMachine.state.editorialFeaturesEnabled == true:
            let query = QueryOn<T>.where(sys: .id, .equals(resource.id))

            deliveryClient.fetchArray(of: T.self, matching: query) { [unowned self] result in
                switch result {
                case .success(let response):
                    let statefulPreviewResource = self.inferStateFromDiffs(
                        previewResource: resource,
                        deliveryResource: response.items.first
                    )

                    completion(.success(statefulPreviewResource), response.items.first)

                case .failure(let error):
                    completion(.failure(error), nil)
                }
            }
            return true
        default:
            // If not connected to the Preview API with editorial features enabled, continue execution without
            // additional state resolution.
            return false
        }
    }

    /// This method takes a parent entry that links to an array of linked `Module`s and will calculate
    /// the states of all those modules by comparing their values on the Preview and Delivery APIs. This method will update the state
    /// of the passed in Preview API parent entry and update it's state property if any of it's linked modules are in "Pending Changes" or in "Draft" states.
    ///
    /// - Parameters:
    ///   - statefulRootAndModules: A tuple of a parent entry and it's linked modules array. The parent and modules
    ///   should both have been fetched from the Preview API.
    ///   - deliveryModules: The same module entities in their most recently published state: i.e. fetched from the Delivery API.
    /// - Returns: A reference to the parent entry with it's state now modified to reflect the collective states of its linked modules.
    public func inferStateFromLinkedModuleDiffs<T>(statefulRootAndModules: (T, [Module]),
                                                   deliveryModules: [Module]) -> T where T: StatefulResource {

        var (previewRoot, previewModules) = statefulRootAndModules
        let deliveryModules = deliveryModules

        // Check for newly linked/unlinked modules.
        if deliveryModules.count != previewModules.count {
            previewRoot.state = .pendingChanges
        }
        // Check if modules have been reordered
        for index in 0..<deliveryModules.count {
            if previewModules[index].sys.id != deliveryModules[index].sys.id {
                previewRoot.state = .pendingChanges
            }
        }

        // Now resolve state for each preview module.
        for i in 0..<previewModules.count {
            let deliveryModule = deliveryModules.filter({ $0.sys.id == previewModules[i].sys.id }).first
            previewModules[i] = inferStateFromDiffs(previewResource: previewModules[i], deliveryResource: deliveryModule)
        }

        let previewModuleStates = previewModules.map { $0.state }
        let numberOfDraftModules =  previewModuleStates.filter({ $0 == .draft }).count
        let numberOfPendingChangesModules =  previewModuleStates.filter({ $0 == .pendingChanges }).count

        // Calculate the state of the root parent entry based on it's linked modules.
        if numberOfDraftModules > 0 && numberOfPendingChangesModules > 0 {
            previewRoot.state = .draftAndPendingChanges
        } else if numberOfDraftModules > 0 && numberOfPendingChangesModules == 0 {
            if previewRoot.state == .pendingChanges {
                previewRoot.state = .draftAndPendingChanges
            } else {
                previewRoot.state = .draft
            }
        } else if numberOfDraftModules == 0 && numberOfPendingChangesModules > 0 {
            if previewRoot.state == .draft {
                previewRoot.state = .draftAndPendingChanges
            } else {
                previewRoot.state = .pendingChanges
            }
        }

        return previewRoot
    }

    /// This method will take a resource that was fetched from The Preview API, and the Wrapping result type returned after fetching
    /// the same resource from the Delivery API and compare the updatedAt dates together to see if the preview resource is "Draft", "Pending changes",
    /// or completely up-to-date.
    ///
    /// - Parameters:
    ///   - previewResource: The Preview API resource for which a state determination will be made.
    ///   - deliveryResult: The result of the Delivery API GET request which fetched the same resource, but with Delivery API values.
    /// - Returns: Returns the preview resource originally passed in, but with it's state property updated.
    private func inferStateFromDiffs<T>(previewResource: T, deliveryResource: T?) -> T where T: StatefulResource & Resource {

        if let deliveryResource = deliveryResource {
            if deliveryResource.sys.updatedAt!.isEqualTo(previewResource.sys.updatedAt!) == false {
                previewResource.state = .pendingChanges
            }
        } else {
            // The Resource is available on the Preview API but not the Delivery API, which means it's in draft.
            previewResource.state = .draft
        }
        return previewResource
    }


    /// Depending on the state of the ContentfulService, this Client will either be connected to the Delivery API, or the Preview API.
    public var client: Client {
        switch stateMachine.state.api {
        case .delivery: return deliveryClient
        case .preview: return previewClient
        }
    }

    /// If connected to the original space which is maintained by Contentful and has read-only access this will return `true`.
    public func isConnectedToDefaultSpace() -> Bool {
        return credentials.spaceId == ContentfulCredentials.default.spaceId
            && credentials.deliveryAPIAccessToken == ContentfulCredentials.default.deliveryAPIAccessToken
            && credentials.previewAPIAccessToken == ContentfulCredentials.default.previewAPIAccessToken
    }
}
