
import Foundation
import Contentful

struct ContentfulCredentials: Codable, Equatable {

    static func ==(lhs: ContentfulCredentials, rhs: ContentfulCredentials) -> Bool {
        return lhs.spaceId == rhs.spaceId && lhs.deliveryAPIAccessToken == rhs.deliveryAPIAccessToken && lhs.previewAPIAccessToken == rhs.previewAPIAccessToken
    }


    let spaceId: String
    let deliveryAPIAccessToken: String
    let previewAPIAccessToken: String

    /**
     * Pulls the default space credentials from the Example App Space owned by Contentful.
     */
    static let `default`: ContentfulCredentials = {
        guard let bundleInfo = Bundle.main.infoDictionary else { fatalError() }

        let spaceId = bundleInfo["CONTENTFUL_SPACE_ID"] as! String
        let deliveryAPIAccessToken = bundleInfo["CONTENTFUL_DELIVERY_TOKEN"] as! String
        let previewAPIAccessToken = bundleInfo["CONTENTFUL_PREVIEW_TOKEN"] as! String

        let credentials = ContentfulCredentials(spaceId: spaceId,
                                                deliveryAPIAccessToken: deliveryAPIAccessToken,
                                                previewAPIAccessToken: previewAPIAccessToken)
        return credentials
    }()

}
