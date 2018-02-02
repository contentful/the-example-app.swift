
@testable import the_example_app_swift
import XCTest
import Nimble

class ContentfulServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults().removeSuite(named: testUserDefaults)
    }

    func testTogglingAPIStates() {

        let initialState = ContentfulService.State(api: .delivery,
                                                   locale: .americanEnglish,
                                                   editorialFeaturesEnabled: false)
        let contentfulService = ContentfulService(session: Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!),
                                                  credentials: .default,
                                                  state: initialState)


        expect(contentfulService.stateMachine.state.editorialFeaturesEnabled).to(equal( false))

        contentfulService.toggleAPI()
        expect(contentfulService.stateMachine.state.api).to(equal(ContentfulService.State.API.preview))

        contentfulService.enableEditorialFeatures(true)
        expect(contentfulService.stateMachine.state.editorialFeaturesEnabled).to(equal(true))

        contentfulService.toggleAPI()
        expect(contentfulService.stateMachine.state.api).to(equal(ContentfulService.State.API.delivery))
    }

    func testTogglingLocales() {
        let initialState = ContentfulService.State(api: .delivery,
                                                   locale: .americanEnglish,
                                                   editorialFeaturesEnabled: false)
        let contentfulService = ContentfulService(session: Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!),
                                                  credentials: .default,
                                                  state: initialState)
        expect(contentfulService.stateMachine.state.locale.code()).to(equal("en-US"))
        contentfulService.toggleLocale()
        expect(contentfulService.stateMachine.state.locale.code()).to(equal("de-DE"))
        contentfulService.toggleLocale()
        expect(contentfulService.stateMachine.state.locale.code()).to(equal("en-US"))
    }
}
