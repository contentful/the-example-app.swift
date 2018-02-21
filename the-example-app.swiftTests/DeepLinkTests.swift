
@testable import the_example_app_swift
import XCTest
import Nimble
import KIF

class DeepLinkTests: KIFTestCase {

    override func setUp() {
        super.setUp()
        (UIApplication.shared.delegate as! AppDelegate).services.resetCredentialsToDefault()
    }

    func testBaseRoute() {
        UIApplication.shared.open(URL(string: "the-example-app.swift://")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "Today's highlighted course: Hello Contentful")
    }

    func testCoursesRoute() {
        UIApplication.shared.open(URL(string: "the-example-app.swift://courses")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "Hello Contentful")
        tester.waitForTappableView(withAccessibilityLabel: "Hello SDKs")
    }


    func testSpecificCourseRoute() {
        UIApplication.shared.open(URL(string: "the-example-app.swift://courses/hello-sdks")!, options: [:], completionHandler: nil)
        
        tester.waitForTappableView(withAccessibilityLabel: "Course overview: Hello SDKs")
    }

    func testLessonRoute() {
        UIApplication.shared.open(URL(string: "the-example-app.swift://courses/hello-sdks/lessons/sdk-basics")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "SDK basics")

        UIApplication.shared.open(URL(string: "the-example-app.swift://courses/hello-sdks/lessons/example-app-summary")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "Summary")
    }

    func testSettingsRoute() {
        UIApplication.shared.open(URL(string: "the-example-app.swift://settings")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "U.S. English")

        // Tapping will cause the system to scroll
        tester.tapView(withAccessibilityLabel: "API: Preview")
        tester.waitForTappableView(withAccessibilityLabel: "API: Preview")
    }

    func testInvalidRoute() {
        UIApplication.shared.open(URL(string: "the-example-app.swift://foo")!, options: [:], completionHandler: nil)

        let expectedAccessibilityLabel = "Oops, something went wrong\nInvalid route \'foo\'"
        tester.waitForTappableView(withAccessibilityLabel: expectedAccessibilityLabel)
        tester.tapView(withAccessibilityLabel: "OK")
        tester.waitForAbsenceOfView(withAccessibilityLabel: expectedAccessibilityLabel)
    }

    func testInvalidCredentialsRoutesToSettings() {
        UIApplication.shared.open(URL(string: "the-example-app.swift://courses?space_id=jnzexv31feqf")!, options: [:], completionHandler: nil)

        let expectedAccessibilityLabel = """
        • This field is required: Content Preview API access token
        • This field is required: Content Delivery API access token

        """
        tester.waitForTappableView(withAccessibilityLabel: expectedAccessibilityLabel)
        let spaceIdField = tester.waitForView(withAccessibilityLabel: "Space ID field")
        tester.expect(spaceIdField, toContainText: "jnzexv31feqf")

        let cdaTokenField = tester.waitForView(withAccessibilityLabel: "Content Delivery API access token field")
        tester.expect(cdaTokenField, toContainText: "")

        let cpaTokenField = tester.waitForView(withAccessibilityLabel: "Content Preview API access token field")
        tester.expect(cpaTokenField, toContainText: "")
    }

    func testSpaceWithoutLessonCopyModulesStillRendersLesson() {
        UIApplication.shared.open(URL(string: "the-example-app.swift://courses/hello-sdks/lessons/fetch-draft-content?space_id=r3rkxrglg2d1&delivery_token=98b2548760939aff3910f23e0b97dc6376e6c7aec5ebf73c5f3424b36b721e50&preview_token=dc4d50c7d811f519d5037f92cbabc1312c822f674a066fa2bfcfc3077cbfb6b0&editorial_features=enabled&api=cpa")!, options: [:], completionHandler: nil)

        tester.waitForView(withAccessibilityLabel: "Fetch draft content")

        let expectedAccessibilityLabel = "New space detected"
        tester.waitForTappableView(withAccessibilityLabel: expectedAccessibilityLabel)
        tester.tapView(withAccessibilityLabel: "OK")
        tester.waitForAbsenceOfView(withAccessibilityLabel: expectedAccessibilityLabel)
    }
}
