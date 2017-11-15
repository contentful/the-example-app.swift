
import Foundation
import Contentful
import Keys

protocol ContentfulService {
    var contentfulClient: Client { get }

    var contentfulPreviewClient: Client { get }
}

class ServiceBus: ContentfulService {

    let contentfulClient: Client

    let contentfulPreviewClient: Client

    static var contentTypeClasses: [EntryDecodable.Type] = [
        Lesson.self,
        LessonCopy.self,
        LessonImage.self,
        LessonSnippets.self
    ]


    init(session: Session) {
        let spaceCredentials = session.spaceCredentials
        self.contentfulClient = Client(spaceId: spaceCredentials.spaceId,
                                       accessToken: spaceCredentials.deliveryAPIAccessToken,
                                       contentTypeClasses: ServiceBus.contentTypeClasses)


        // This time, we configure the client to pull content from the Preview API.
        var previewConfiguration = ClientConfiguration()
        previewConfiguration.previewMode = true
        self.contentfulPreviewClient = Client(spaceId: spaceCredentials.spaceId,
                                              accessToken: spaceCredentials.previewAPIAccessToken,
                                              clientConfiguration: previewConfiguration,
                                              contentTypeClasses: ServiceBus.contentTypeClasses)
    }


}
