
import Foundation
import Contentful

/// A class which manages information about the active session of the application.
/// It handles persisting and expiring session information to the application's specifications created by Contentful.
final class Session {

    private enum Constant {
        static let userDefaultsCredentialsKey = "credentials"
        static let lastTimeCredentialsPersistedKey = "lastTimeCredentialsPersisted"
        static let lastTimeEditorialFeaturesPersistedKey = "lastTimeEditorialFeaturesPersisted"
        static let lastTimeLocalePersistedKey = "lastTimeLocalePersistedPersisted"
        static let lastTimeAPIPersistedKey = "lastTimeAPIPersisted"

        static let editorialFeaturesEnabledKey = "editorialFeaturesEnabled"
        static let contentfulLocaleKey = "contentfulLocale"
        static let contentfulAPIKey = "contentfulAPI"

        static let twoDays: TimeInterval = 172800
    }

    var spaceCredentials: ContentfulCredentials

    private let userDefaults: UserDefaults

    init(
        userDefaults: UserDefaults = .standard,
        sessionExpirationWindow: TimeInterval = Constant.twoDays
    ) {
        self.userDefaults = userDefaults

        if let data = userDefaults.data(forKey: Constant.userDefaultsCredentialsKey),
            let credentials = try? JSONDecoder().decode(ContentfulCredentials.self, from: data),
            let lastPersistDate = userDefaults.object(forKey: Constant.lastTimeCredentialsPersistedKey) as? Date,
            Date().timeIntervalSince(lastPersistDate) <= sessionExpirationWindow {
            spaceCredentials = credentials
        } else {
            spaceCredentials = .default
        }

        // Reset the editorial features if the we've passsed the expiration date.
        if let lastPersistDate = userDefaults.object(forKey: Constant.lastTimeEditorialFeaturesPersistedKey) as? Date,
            Date().timeIntervalSince(lastPersistDate) > sessionExpirationWindow {
            persistEditorialFeatureState(isOn: false)
        }

        if let lastPersistDate = userDefaults.object(forKey: Constant.lastTimeLocalePersistedKey) as? Date,
            Date().timeIntervalSince(lastPersistDate) > sessionExpirationWindow {
            persistLocale(Contentful.Locale.americanEnglish())
        }

        if let lastPersistDate = userDefaults.object(forKey: Constant.lastTimeAPIPersistedKey) as? Date,
            Date().timeIntervalSince(lastPersistDate) > sessionExpirationWindow {
            persistAPI(StatefulContentfulClientProvider.State.API.delivery)
        }
    }

    func persistLocale(_ locale: Contentful.Locale) {
        userDefaults.set(locale.code, forKey: Constant.contentfulLocaleKey)
        userDefaults.set(Date(), forKey: Constant.lastTimeLocalePersistedKey)
    }

    func persistedLocaleCode() -> String? {
        return userDefaults.string(forKey: Constant.contentfulLocaleKey)
    }

    func persistedAPIRawValue() -> String? {
        return userDefaults.string(forKey: Constant.contentfulAPIKey)
    }

    func persistAPI(_ api: StatefulContentfulClientProvider.State.API) {
        userDefaults.set(api.rawValue, forKey: Constant.contentfulAPIKey)
        userDefaults.set(Date(), forKey: Constant.lastTimeAPIPersistedKey)
    }

    func persistEditorialFeatureState(isOn: Bool) {
        userDefaults.set(isOn, forKey: Constant.editorialFeaturesEnabledKey)
        // Update persistence window.
        userDefaults.set(Date(), forKey: Constant.lastTimeEditorialFeaturesPersistedKey)
    }

    func areEditorialFeaturesEnabled() -> Bool {
        return userDefaults.bool(forKey: Constant.editorialFeaturesEnabledKey)
    }

    func persistCredentials() {
        if let data = try? JSONEncoder().encode(self.spaceCredentials) {
            userDefaults.set(data, forKey: Constant.userDefaultsCredentialsKey)
            // Update persistence window.
            userDefaults.set(Date(), forKey: Constant.lastTimeCredentialsPersistedKey)
        }
    }
}



