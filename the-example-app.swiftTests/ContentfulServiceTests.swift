
import XCTest
import Nimble
@testable import the_example_app_swift


class ContentfulServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults().removeSuite(named: testUserDefaults)
    }

    func testTogglingAPIStates() {

        let contentfulService = ContentfulService(session: Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!),
                                                  credentials: .default,
                                                  state: .delivery(editorialFeatureEnabled: false))

        expect(contentfulService.apiStateMachine.state).to(equal(.delivery(editorialFeatureEnabled: false)))

        contentfulService.toggleAPI()
        expect(contentfulService.apiStateMachine.state).to(equal(.preview(editorialFeatureEnabled: false)))

        contentfulService.enableEditorialFeatures(true)
        expect(contentfulService.apiStateMachine.state).to(equal(.preview(editorialFeatureEnabled: true)))

        contentfulService.toggleAPI()
        expect(contentfulService.apiStateMachine.state).to(equal(.delivery(editorialFeatureEnabled: true)))
    }

    func testTogglingLocales() {
        let contentfulService = ContentfulService(session: Session(userDefaults: UserDefaults(suiteName: testUserDefaults)!),
                                                  credentials: .default,
                                                  state: .delivery(editorialFeatureEnabled: false))
        expect(contentfulService.localeStateMachine.state.code()).to(equal("en-US"))
        contentfulService.toggleLocale()
        expect(contentfulService.localeStateMachine.state.code()).to(equal("de-DE"))
        contentfulService.toggleLocale()
        expect(contentfulService.localeStateMachine.state.code()).to(equal("en-US"))
    }


}
