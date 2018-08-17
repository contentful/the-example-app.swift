
import Foundation
import Contentful

extension TimeInterval {
    static let twoDays: TimeInterval = 172800
}

/// A class which manages information about the active session of the application.
/// It handles persisting and expiring session information to the application's specifications created by Contentful.
class Session {

    static let userDefaultsCredentialsKey = "credentials"
    static let lastTimeCredentialsPersistedKey = "lastTimeCredentialsPersisted"
    static let lastTimeEditorialFeaturesPersistedKey = "lastTimeEditorialFeaturesPersisted"
    static let lastTimeLocalePersistedKey = "lastTimeLocalePersistedPersisted"
    static let lastTimeAPIPersistedKey = "lastTimeAPIPersisted"

    static let editorialFeaturesEnabledKey = "editorialFeaturesEnabled"
    static let contentfulLocaleKey = "contentfulLocale"
    static let contentfulAPIKey = "contentfulAPI"

    static let twoDays: TimeInterval = 172800

    var spaceCredentials: ContentfulCredentials

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

        // Reset the editorial features if the we've passsed the expiration date.
        if let lastPersistDate = userDefaults.object(forKey: Session.lastTimeEditorialFeaturesPersistedKey) as? Date,
            Date().timeIntervalSince(lastPersistDate) > sessionExpirationWindow {
            persistEditorialFeatureState(isOn: false)
        }

        if let lastPersistDate = userDefaults.object(forKey: Session.lastTimeLocalePersistedKey) as? Date,
            Date().timeIntervalSince(lastPersistDate) > sessionExpirationWindow {
            persistLocale(Contentful.Locale.americanEnglish())
        }

        if let lastPersistDate = userDefaults.object(forKey: Session.lastTimeAPIPersistedKey) as? Date,
            Date().timeIntervalSince(lastPersistDate) > sessionExpirationWindow {
            persistAPI(ContentfulService.State.API.delivery)
        }
    }

    public func persistLocale(_ locale: Contentful.Locale) {
        userDefaults.set(locale.code, forKey: Session.contentfulLocaleKey)
        userDefaults.set(Date(), forKey: Session.lastTimeLocalePersistedKey)
    }

    public func persistedLocaleCode() -> String? {
        return userDefaults.string(forKey: Session.contentfulLocaleKey)
    }

    public func persistedAPIRawValue() -> String? {
        return userDefaults.string(forKey: Session.contentfulAPIKey)
    }

    public func persistAPI(_ api: ContentfulService.State.API) {
        userDefaults.set(api.rawValue, forKey: Session.contentfulAPIKey)
        userDefaults.set(Date(), forKey: Session.lastTimeAPIPersistedKey)
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



