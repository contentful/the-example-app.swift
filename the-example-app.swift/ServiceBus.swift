
import Foundation
import Contentful
import Interstellar
import Keys

class ResourceStateResolver {

}

enum ResourceState {
    case upToDate
    case draft
    case pendingChanges
}

struct StatefulResource  {
    var sys: Sys
    var state: ResourceState
}

class ContentfulService {

    /// The client used to pull data from the Content Delivery API.
    private let deliveryClient: Client

    /// The client used to pull data from the Content Preview API.
    private let previewClient: Client

    var resourceStateResolver: ResourceStateResolver?

    private var state: State

    enum State {
        case delivery(editorialFeatureEnabled: Bool)
        case preview(editorialFeatureEnabled: Bool)
    }

//
//    func fetchMappedEntries<EntryType>(matching query: QueryOn<EntryType>,
//                                       then completion: @escaping (Result<MappedArrayResponse<EntryType>>) -> Void) -> URLSessionDataTask? {
//
//        client().fetchMappedEntries(matching: query) { [unowned self] result in
//            completion(result)
//            switch self.state {
//            case .delivery:
//                completion(result)
//            case .preview(let editorialFeaturesEnabled):
//                self.deliveryClient.fetchMappedEntries(matching: query) { deliveryResult in
////                    let
//                }
//            }
//        }
//        return nil
//    }

    public func client() -> Client {
        switch state {
        case .delivery: return deliveryClient
        case .preview: return previewClient
        }
    }
    
    init(credentials: ContentfulCredentials, state: State = .delivery(editorialFeatureEnabled: false)) {
        self.state = state

        self.deliveryClient = Client(spaceId: credentials.spaceId,
                                     accessToken: credentials.deliveryAPIAccessToken,
                                     contentTypeClasses: ServiceBus.contentTypeClasses)

        // This time, we configure the client to pull content from the Content Preview API.
        var previewConfiguration = ClientConfiguration()
        previewConfiguration.previewMode = true
        self.previewClient = Client(spaceId: credentials.spaceId,
                                    accessToken: credentials.previewAPIAccessToken,
                                    clientConfiguration: previewConfiguration,
                                    contentTypeClasses: ServiceBus.contentTypeClasses)
    }
}

class ServiceBus {

    var contentfulService: ContentfulService

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
        contentfulService = ContentfulService(credentials: spaceCredentials)
    }
}
