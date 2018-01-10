
import Foundation
import Contentful

extension TimeInterval {
    static let twoDays: TimeInterval = 172800
}

class Session {

    static let userDefaultsCredentialsKey = "credentials"
    static let lastTimeCredentialsPersistedKey = "lastTimeCredentialsPersisted"
    static let lastTimeEditorialFeaturesPersistedKey = "lastTimeEditorialFeaturesPersisted"

    static let editorialFeaturesEnabledKey = "editorialFeaturesEnabled"

    static let twoDays: TimeInterval = 172800

    var spaceCredentials: ContentfulCredentials

    func updateCredentialsFromURL(_ url: URL, then completion: (() -> Void)?) {
        // TODO:
    }

    func resetToDefaultCredentials() {
        spaceCredentials = .default
        persistCredentials()
    }

    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard, sessionExpirationWindow: TimeInterval = .twoDays) {
        self.userDefaults = userDefaults

        if let data = userDefaults.data(forKey: Session.userDefaultsCredentialsKey),
            let credentials = try? JSONDecoder().decode(ContentfulCredentials.self, from: data),
            let lastPersistDate = userDefaults.object(forKey: Session.lastTimeCredentialsPersistedKey) as? Date,
            Date().timeIntervalSince(lastPersistDate) <= sessionExpirationWindow {
            spaceCredentials = credentials
        } else {
            spaceCredentials = .default
        }

        // Reset the editorial features if the we've passsed the experiation date.
        guard let lastPersistDate = userDefaults.object(forKey: Session.lastTimeEditorialFeaturesPersistedKey) as? Date,
            Date().timeIntervalSince(lastPersistDate) <= sessionExpirationWindow else {
            persistEditorialFeatureState(isOn: false)
            return
        }
    }

    public func persistEditorialFeatureState(isOn: Bool) {
        userDefaults.set(isOn, forKey: Session.editorialFeaturesEnabledKey)
        // Update persistence window.
        userDefaults.set(Date(), forKey: Session.lastTimeEditorialFeaturesPersistedKey)
    }

    func areEditorialFeaturesEnabled() -> Bool {
        return userDefaults.bool(forKey: Session.editorialFeaturesEnabledKey)
    }

    public func persistCredentials() {
        if let data = try? JSONEncoder().encode(self.spaceCredentials) {
            userDefaults.set(data, forKey: Session.userDefaultsCredentialsKey)
            // Update persistence window.
            userDefaults.set(Date(), forKey: Session.lastTimeCredentialsPersistedKey)
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
