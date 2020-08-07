//
//  Copyright © 2020 Contentful. All rights reserved.
//

import Contentful
import Foundation

final class ContentfulClientProvider {

    let deliveryClient: Client
    let previewClient: Client

    init(credentials: ContentfulCredentials) {
        self.deliveryClient = Client(
            spaceId: credentials.spaceId,
            accessToken: credentials.deliveryAPIAccessToken,
            host: "cdn." + credentials.domainHost,
            contentTypeClasses: ContentfulClientProvider.contentTypeClasses
        )

        // This time, we configure the client to pull content from the Content Preview API.
        self.previewClient = Client(
            spaceId: credentials.spaceId,
            accessToken: credentials.previewAPIAccessToken,
            host: "preview." + credentials.domainHost,
            contentTypeClasses: ContentfulClientProvider.contentTypeClasses
        )
    }

    /// An array of all the content types that will be used by the apps instance of `ContentfulService`.
    private static var contentTypeClasses: [EntryDecodable.Type] = [
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
