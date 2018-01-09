
import Foundation
import Contentful

class Session {

    static let userDefaultsCredentialsKey = "credentials"

    var spaceCredentials: ContentfulCredentials

    func updateCredentialsFromURL(_ url: URL, then completion: (() -> Void)?) {}

    func resetToDefaultCredentials() {
        spaceCredentials = .default
        persistCredentials()
    }

    init() {

        if let data = UserDefaults.standard.data(forKey: Session.userDefaultsCredentialsKey),
            let credentials = try? JSONDecoder().decode(ContentfulCredentials.self, from: data) {
            spaceCredentials = credentials
        } else {
            spaceCredentials = .default
            persistCredentials()
        }
    }

    func persistCredentials() {
        if let data = try? JSONEncoder().encode(self.spaceCredentials) {
            UserDefaults.standard.set(data, forKey: Session.userDefaultsCredentialsKey)
        }
    }
}


struct ContentfulCredentials: Codable {

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
