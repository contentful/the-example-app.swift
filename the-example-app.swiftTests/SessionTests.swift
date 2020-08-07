
@testable import the_example_app_swift
import XCTest
import Nimble
import Contentful

let testUserDefaults = "TestDefaults"

class SessionTests: XCTestCase {

    func testSessionExpiration() {
        let testExpirationWindow = 1.0
        var session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)
        expect(session.spaceCredentials.spaceId).to(equal("qz0n5cdakyl9"))
        expect(session.spaceCredentials.deliveryAPIAccessToken).to(equal("b2b980b80e4154cb8cdd1d3b156d7b5d17f5eeb3ba3b1035db39cc842b199866"))
        expect(session.spaceCredentials.previewAPIAccessToken).to(equal("96ebcdba21ac23ad89242904bac3bcf7a5cc2eba784eb152996584d0e0ebc16e"))

        // Assign new credentials from QA space.
        session.spaceCredentials = ContentfulCredentials(spaceId: "jnzexv31feqf",
                                                         deliveryAPIAccessToken: "c4db7583b6a0b76a3d476f43c75b623445e7c45089e35854a1b4860dc7f83cc5",
                                                         previewAPIAccessToken: "9839e941d85a3649c6469714353e37a93804f8a5d7667075919afe5416f87619",
                                                         domainHost: ContentfulCredentials.defaultDomainHost)
        session.persistCredentials()

        // Reinit session.
        session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)
        expect(session.spaceCredentials.spaceId).to(equal("jnzexv31feqf"))
        expect(session.spaceCredentials.deliveryAPIAccessToken).to(equal("c4db7583b6a0b76a3d476f43c75b623445e7c45089e35854a1b4860dc7f83cc5"))
        expect(session.spaceCredentials.previewAPIAccessToken).to(equal("9839e941d85a3649c6469714353e37a93804f8a5d7667075919afe5416f87619"))

        sleep(UInt32(testExpirationWindow + 1.0))

        // Expect credentials to be reverted
        session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)
        expect(session.spaceCredentials.spaceId).to(equal("qz0n5cdakyl9"))
        expect(session.spaceCredentials.deliveryAPIAccessToken).to(equal("b2b980b80e4154cb8cdd1d3b156d7b5d17f5eeb3ba3b1035db39cc842b199866"))
        expect(session.spaceCredentials.previewAPIAccessToken).to(equal("96ebcdba21ac23ad89242904bac3bcf7a5cc2eba784eb152996584d0e0ebc16e"))
    }

    func testPersistingEditorialFeatureSelection() {
        let testExpirationWindow = 1.0
        var session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)

        session.persistEditorialFeatureState(isOn: true)
        expect(session.areEditorialFeaturesEnabled()).to(equal(true))

        // Check that editorial features are persisted after reinitializing session
        session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)
        expect(session.areEditorialFeaturesEnabled()).to(equal(true))

        sleep(UInt32(testExpirationWindow + 1.0))

        // Check that editorial features selection reverts to default after expiration window
        session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)
        expect(session.areEditorialFeaturesEnabled()).to(equal(false))
    }

    func testPersistingLocaleSelection() {
        let testExpirationWindow = 1.0
        var session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)

        session.persistLocale(.german())
        expect(session.persistedLocaleCode()).to(equal(Contentful.Locale.german().code))

        // Check that locale is persisted after reinitializing session
        session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)
        expect(session.persistedLocaleCode()).to(equal(Contentful.Locale.german().code))

        sleep(UInt32(testExpirationWindow + 1.0))

        // Check that locale reverts to default after expiration window
        session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)
        expect(session.persistedLocaleCode()).to(equal(Contentful.Locale.americanEnglish().code))
    }

    func testPersistingAPISelection() {
        let testExpirationWindow = 1.0
        var session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)

        session.persistAPI(.preview)
        expect(session.persistedAPIRawValue()).to(equal(StatefulContentfulClientProvider.State.API.preview.rawValue))

        // Check that api is persisted after reinitializing session
        session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)
        expect(session.persistedAPIRawValue()).to(equal(StatefulContentfulClientProvider.State.API.preview.rawValue))

        sleep(UInt32(testExpirationWindow + 1.0))

        // Check that api reverts to default after expiration window
        session = Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!, sessionExpirationWindow: testExpirationWindow)
        expect(session.persistedAPIRawValue()).to(equal(StatefulContentfulClientProvider.State.API.delivery.rawValue))    }
}
