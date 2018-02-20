
import Foundation
import Contentful
import Interstellar
import DeepLinkKit

enum ResourceState {
    case upToDate
    case draft
    case pendingChanges
    case draftAndPendingChanges
}

protocol StatefulResource: class {
    var state: ResourceState { get set }
}

extension Contentful.Locale: Equatable {}
public func ==(lhs: Contentful.Locale, rhs: Contentful.Locale) -> Bool {
    return lhs.code == rhs.code && lhs.name == rhs.name && lhs.fallbackLocaleCode == rhs.fallbackLocaleCode && lhs.isDefault == rhs.isDefault
}

extension Contentful.Locale {

    /// The default locale of this application and of the associated space in Contentful.
    static func americanEnglish() -> Contentful.Locale {
        let jsonData = """
        {
            "code": "en-US",
            "default": true,
            "name": "U.S. English",
            "fallbackCode": null
        }
        """.data(using: .utf8)!

        let locale = try! JSONDecoder().decode(Contentful.Locale.self, from: jsonData)
        return locale
    }

    static func german() -> Contentful.Locale {
        let jsonData = """
        {
            "code": "de-DE",
            "default": false,
            "name": "German (Germany)",
            "fallbackCode": "en-US"
        }
        """.data(using: .utf8)!
        
        let locale = try! JSONDecoder().decode(Contentful.Locale.self, from: jsonData)
        return locale
    }

}

class ContentfulService {

    struct State {

        var api: API
        var locale: Contentful.Locale
        var editorialFeaturesEnabled: Bool

        public enum API {
            case delivery
            case preview

            func title() -> String {
                switch self {
                case .delivery:
                    return "API: Delivery"
                case .preview:
                    return "API: Preview"
                }
            }
        }
    }

    public let stateMachine: StateMachine<ContentfulService.State>

    /// The client used to pull data from the Content Delivery API.
    public let deliveryClient: Client

    /// The client used to pull data from the Content Preview API.
    public let previewClient: Client

    public let deliveryAccessToken: String
    public let previewAccessToken: String
    public let spaceId: String

    public func toggleAPI() {
        switch stateMachine.state.api {
        case .delivery:
            stateMachine.state.api = .preview
        case .preview:
            stateMachine.state.api = .delivery
        }
    }

    public func enableEditorialFeatures(_ shouldEnable: Bool) {
        session.persistEditorialFeatureState(isOn: shouldEnable)
        stateMachine.state.editorialFeaturesEnabled = shouldEnable
    }

    public var shouldShowResourceStateLabels: Bool {
        return editorialFeaturesAreEnabled && stateMachine.state.api == .preview
    }

    public var editorialFeaturesAreEnabled: Bool {
        return stateMachine.state.editorialFeaturesEnabled
    }

    public var locales: [Contentful.Locale] {

        // FIXME: This is not actually blocking
        let dispatchGroup = DispatchGroup()

        var locales = [Contentful.Locale]()

        client.fetchSpace() { result in
            dispatchGroup.enter()
            if let space = result.value {
                locales = space.locales
            } else {
                locales = [.americanEnglish(), .german()]
            }
            dispatchGroup.leave()
        }
        return locales
    }

    var currentLocaleCode: LocaleCode {
        return stateMachine.state.locale.code
    }

    @discardableResult public func willResolveStateIfNecessary<T>(for resource: T,
                                                                  then completion: @escaping (Result<T>, T?) -> Void) -> Bool
        where T: ResourceQueryable & EntryDecodable & StatefulResource {

        switch stateMachine.state.api {

        case .preview where stateMachine.state.editorialFeaturesEnabled == true:
            let query = QueryOn<T>.where(sys: .id, .equals(resource.sys.id))

            deliveryClient.fetchMappedEntries(matching: query) { [unowned self] deliveryResult in
                if let error = deliveryResult.error {
                    completion(Result.error(error), nil)
                }

                let statefulPreviewResource = self.inferStateFromDiffs(previewResource: resource, deliveryResult: deliveryResult)
                completion(Result.success(statefulPreviewResource), deliveryResult.value?.items.first)
            }
            return true
        default:
            // If not connected to the Preview API with editorial features enabled, continue execution without
            // additional state resolution.
            return false
        }
    }

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
            let deliveryModule = deliveryModules.filter({ $0.id == previewModules[i].id }).first
            previewModules[i] = inferStateFromDiffs(previewResource: previewModules[i], deliveryResource: deliveryModule)
        }

        let previewModuleStates = previewModules.map { $0.state }
        let numberOfDraftModules =  previewModuleStates.filter({ $0 == .draft }).count
        let numberOfPendingChangesModules =  previewModuleStates.filter({ $0 == .pendingChanges }).count

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

    private func inferStateFromDiffs<T>(previewResource: T, deliveryResult: Result<MappedArrayResponse<T>>) -> T where T: StatefulResource {

        if let deliveryResource = deliveryResult.value?.items.first  {
            if deliveryResource.sys.updatedAt!.isEqualTo(previewResource.sys.updatedAt!) == false {
                previewResource.state = .pendingChanges
            }
        } else {
            // The Resource is available on the Preview API but not the Delivery API, which means it's in draft.
            previewResource.state = .draft
        }
        return previewResource
    }

    public func inferStateFromDiffs<T>(previewResource: T, deliveryResource: T?) -> T where T: StatefulResource & Resource {

        if let deliveryResource = deliveryResource {
            if deliveryResource.sys.updatedAt!.isEqualTo(previewResource.sys.updatedAt!) == false {
                previewResource.state = .pendingChanges
            }
        } else {
            // The Resource is available on     the Preview API but not the Delivery API, which means it's in draft.
            previewResource.state = .draft
        }
        return previewResource
    }

    public var client: Client {
        switch stateMachine.state.api {
        case .delivery: return deliveryClient
        case .preview: return previewClient
        }
    }

    public func isConnectedToDefaultSpace() -> Bool {
        return spaceId == ContentfulCredentials.default.spaceId
            && deliveryAccessToken == ContentfulCredentials.default.deliveryAPIAccessToken
            && previewAccessToken == ContentfulCredentials.default.previewAPIAccessToken
    }

    let session: Session

    init(session: Session, credentials: ContentfulCredentials, state: State) {
        self.session = session
        self.spaceId = credentials.spaceId
        self.deliveryAccessToken = credentials.deliveryAPIAccessToken
        self.previewAccessToken = credentials.previewAPIAccessToken

        self.deliveryClient = Client(spaceId: credentials.spaceId,
                                     accessToken: credentials.deliveryAPIAccessToken,
                                     contentTypeClasses: ContentfulService.contentTypeClasses)

        // This time, we configure the client to pull content from the Content Preview API.
        var previewConfiguration = ClientConfiguration()
        previewConfiguration.previewMode = true
        self.previewClient = Client(spaceId: credentials.spaceId,
                                    accessToken: credentials.previewAPIAccessToken,
                                    clientConfiguration: previewConfiguration,
                                    contentTypeClasses: ContentfulService.contentTypeClasses)


        self.stateMachine = StateMachine<State>(initialState: state)
    }

    static var contentTypeClasses: [EntryDecodable.Type] = [
        HomeLayout.self,
        LayoutCopy.self,
        LayoutHeroImage.self,
        Course.self,
        LayoutHighlightedCourse.self,
        Lesson.self,
        LessonCopy.self,
        LessonImage.self,
        LessonSnippets.self,
        Category.self
    ]
}
extension ContentfulService.State.API: Equatable {}

func ==(lhs: ContentfulService.State.API, rhs: ContentfulService.State.API) -> Bool {
    switch (lhs, rhs) {
    case (.delivery, .delivery):    return true
    case (.preview, .preview):      return true
    default:                        return false
    }
}

extension Date {

    func isEqualTo(_ date: Date) -> Bool {
        // Strip units smaller than seconds from the date
        let comparableComponenets: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second, .timeZone]
        guard let newSelf = Calendar.current.date(from: Calendar.current.dateComponents(comparableComponenets, from: self)) else {
            fatalError("Failed to strip milliseconds from Date object")
        }
        guard let newComparisonDate = Calendar.current.date(from: Calendar.current.dateComponents(comparableComponenets, from: date)) else {
            fatalError("Failed to strip milliseconds from Date object")
        }

        return newSelf == newComparisonDate
    }
}

