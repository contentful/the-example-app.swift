
import Foundation
import Contentful
import Interstellar
import Keys
import AlamofireImage

enum ResourceState {
    case upToDate
    case draft
    case pendingChanges
}

protocol StatefulResource: class {
    var state: ResourceState { get set }
}

class Contentful {

    /// The client used to pull data from the Content Delivery API.
    private let deliveryClient: Client

    /// The client used to pull data from the Content Preview API.
    private let previewClient: Client

    public func toggleAPI() {
        switch apiStateMachine.state {
        case .delivery(let editiorialFeatures):
            apiStateMachine.state = .preview(editorialFeatureEnabled: editiorialFeatures)
        case .preview(let editiorialFeatures):
            apiStateMachine.state = .delivery(editorialFeatureEnabled: editiorialFeatures)
        }
    }

    public func toggleLocale() {
        switch localeStateMachine.state {
        case .americanEnglish:
            localeStateMachine.state = .german
        case .german:
            localeStateMachine.state = .americanEnglish
        }
    }

    public func toggleEditorialFeaturesEnabled() {
        switch apiStateMachine.state {
        case .delivery(let editiorialFeatures):
            apiStateMachine.state = .delivery(editorialFeatureEnabled: !editiorialFeatures)
        case .preview(let editiorialFeatures):
            apiStateMachine.state = .preview(editorialFeatureEnabled: !editiorialFeatures)
        }
    }

    let apiStateMachine: StateMachine<Contentful.State>

    let localeStateMachine: StateMachine<Contentful.Locale>

    var currentLocaleCode: LocaleCode {
        return localeStateMachine.state.code()
    }

    public func resolveStateIfNecessary<T>(for resource: T, then completion: @escaping ResultsHandler<T>) where T: ResourceQueryable & EntryDecodable & StatefulResource {

        switch apiStateMachine.state {

        case .preview(let editorialFeatureEnabled) where editorialFeatureEnabled == true:
            let query = QueryOn<T>.where(sys: .id, .equals(resource.sys.id))

            deliveryClient.fetchMappedEntries(matching: query) { [unowned self] result in
                if let error = result.error {
                    completion(Result.error(error))
                }

                let statefulResource = self.inferStateFromDiffs(previewResource: resource, deliveryResult: result)
                completion(Result.success(statefulResource))
            }
        default:
            // If not connected to the Preview API with editorial features enabled, continue execution without
            // additional state resolution.
            break
        }
    }

    private func inferStateFromDiffs<T>(previewResource: T, deliveryResult: Result<MappedArrayResponse<T>>) -> T where T: StatefulResource {
        if let statefulResource = deliveryResult.value?.items.first  {
            if statefulResource.sys.updatedAt != previewResource.sys.updatedAt {
                previewResource.state = .pendingChanges
            }
        } else {
            // The Resource is available on the Preview API but not the Delivery API, which means it's in draft.
            previewResource.state = .draft
        }
        return previewResource
    }

    enum Locale {
        case americanEnglish
        case german

        func code() -> LocaleCode {
            // TODO: use locales from space.
            switch self {
            case .americanEnglish:
                return "en-US"
            case .german:
                return "de-DE"
            }
        }

        func barButtonTitle() -> String {
            switch self {
            case .americanEnglish:
                return "English"
            case .german:
                return "German"
            }
        }
    }

    func localeBarButtonTitle() -> String {
        return localeStateMachine.state.barButtonTitle()
    }

    func apiBarButtonTitle() -> String {
        return apiStateMachine.state.barButtonTitle()
    }

    enum State {
        case delivery(editorialFeatureEnabled: Bool)
        case preview(editorialFeatureEnabled: Bool)

        func barButtonTitle() -> String {
            switch self {
            case .delivery:
                return "API: Delivery"
            case .preview:
                return "API: Preview"
            }
        }

    }

    public var client: Client {
        switch apiStateMachine.state {
        case .delivery: return deliveryClient
        case .preview: return previewClient
        }
    }
    
    init(credentials: ContentfulCredentials, state: State = .delivery(editorialFeatureEnabled: false)) {

        self.deliveryClient = Client(spaceId: credentials.spaceId,
                                     accessToken: credentials.deliveryAPIAccessToken,
                                     contentTypeClasses: Services.contentTypeClasses)

        // This time, we configure the client to pull content from the Content Preview API.
        var previewConfiguration = ClientConfiguration()
        previewConfiguration.previewMode = true
        self.previewClient = Client(spaceId: credentials.spaceId,
                                    accessToken: credentials.previewAPIAccessToken,
                                    clientConfiguration: previewConfiguration,
                                    contentTypeClasses: Services.contentTypeClasses)


        // TODO: pull session state.
        self.apiStateMachine = StateMachine<State>(initialState: .delivery(editorialFeatureEnabled: false))
        self.localeStateMachine = StateMachine<Locale>(initialState: .americanEnglish)

    }
}

class Services {

    var contentful: Contentful

    static var contentTypeClasses: [EntryDecodable.Type] = [
        HomeLayout.self,
        Course.self,
        HighlightedCourse.self,
        Lesson.self,
        LessonCopy.self,
        LessonImage.self,
        LessonSnippets.self,
        Category.self
    ]

    init(session: Session) {
        let spaceCredentials = session.spaceCredentials
        contentful = Contentful(credentials: spaceCredentials)
    }
}
