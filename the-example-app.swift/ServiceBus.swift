
import Foundation
import Contentful
import Keys


class EntryStateResolver {

}

class ContentfulProvider {

    /// The client used to pull data from the Content Delivery API.
    let deliveryClient: Client

    /// The client used to pull data from the Content Preview API.
    let previewClient: Client

    var entryStateResolver: EntryStateResolver?

    var state: State

    enum State {
        case delivery(editorialFeatureEnabled: Bool)
        case preview(editorialFeatureEnabled: Bool)
    }

    func client() -> Client {
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

    var contentfulProvider: ContentfulProvider

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
        contentfulProvider = ContentfulProvider(credentials: spaceCredentials)
    }
}
