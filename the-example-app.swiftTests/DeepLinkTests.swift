
@testable import the_example_app_swift
import XCTest
import Nimble
import KIF

class DeepLinkTests: KIFTestCase {

    override func setUp() {
        super.setUp()
        (UIApplication.shared.delegate as! AppDelegate).services.resetCredentialsAndResetLocaleIfNecessary()
        // The method above will only reset the locale if the default space doesn't contain the last selected locale.
        // We must reset to english for these end-to-end tests to pass.
        (UIApplication.shared.delegate as! AppDelegate).services.contentful.setLocale(.americanEnglish())
        (UIApplication.shared.delegate as! AppDelegate).services.contentful.setAPI(.delivery)

        // For some reason, the test suite will crash unless some time is given for the system to reset.
        Thread.sleep(forTimeInterval: 1.0)
    }

    func testBaseRoute() {
        UIApplication.shared.open(URL(string: "the-example-app-mobile://")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "Today's highlighted course: Hello Contentful")
    }

    func testCoursesRoute() {
        UIApplication.shared.open(URL(string: "the-example-app-mobile://courses")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "Hello Contentful")
        tester.waitForTappableView(withAccessibilityLabel: "Hello SDKs")
    }

    func testSpecificCourseRoute() {
        UIApplication.shared.open(URL(string: "the-example-app-mobile://courses/hello-sdks")!, options: [:], completionHandler: nil)
        
        tester.waitForTappableView(withAccessibilityLabel: "Course overview: Hello SDKs")
    }

    func testCategoryRoute() {
        UIApplication.shared.open(URL(string: "the-example-app-mobile://courses/categories/getting-started")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "Hello Contentful")

        // There should only be one course cell since there is a category filter so let's ensure that the "Hello SDKs" course isn't there.
        do {
            try tester.tryFindingView(withAccessibilityLabel: "Hello SDKs")
            Nimble.fail()
        } catch {
            XCTAssert(true)
        }

        // Reset.
        let expectation = self.expectation(description: "")
        (UIApplication.shared.delegate as! AppDelegate).router.tabBarController?.showCoursesViewController { coursesViewController in
            coursesViewController.select(category: nil)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testLessonRoute() {
        UIApplication.shared.open(URL(string: "the-example-app-mobile://courses/hello-sdks/lessons/sdk-basics")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "SDK basics")

        UIApplication.shared.open(URL(string: "the-example-app-mobile://courses/hello-sdks/lessons/example-app-summary")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "Summary")
    }

    func testSettingsRoute() {
        UIApplication.shared.open(URL(string: "the-example-app-mobile://settings")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "English (United States)")

        // Tapping will cause the system to scroll
        tester.tapView(withAccessibilityLabel: "API: Preview")
        tester.waitForTappableView(withAccessibilityLabel: "API: Preview")
    }

    func testInvalidRoute() {
        UIApplication.shared.open(URL(string: "the-example-app-mobile://foo")!, options: [:], completionHandler: nil)

        let expectedAccessibilityLabel = "Oops, something went wrong\nInvalid route \'foo\'"
        tester.waitForTappableView(withAccessibilityLabel: expectedAccessibilityLabel)
        tester.tapView(withAccessibilityLabel: "OK")
        tester.waitForAbsenceOfView(withAccessibilityLabel: expectedAccessibilityLabel)
    }

    func testInvalidCredentialsRoutesToSettings() {
        UIApplication.shared.open(URL(string: "the-example-app-mobile://courses?space_id=jnzexv31feqf")!, options: [:], completionHandler: nil)

        wait(for: 3.0)

        guard let expectedAccessibilityLabel = getAllAccessibilityLabelInWindows()
            .first(where: { $0.contains("This field is required") })
        else {
            XCTFail()
            return
        }

        tester.waitForTappableView(withAccessibilityLabel: expectedAccessibilityLabel)
    }

    func testSpaceWithoutLessonCopyModulesStillRendersLesson() {
        UIApplication.shared.open(URL(string: "the-example-app-mobile://courses/how-the-example-app-is-built/lessons/fetch-draft-content?space_id=jnzexv31feqf&delivery_token=c4db7583b6a0b76a3d476f43c75b623445e7c45089e35854a1b4860dc7f83cc5&preview_token=9839e941d85a3649c6469714353e37a93804f8a5d7667075919afe5416f87619&editorial_features=enabled&api=cpa")!, options: [:], completionHandler: nil)

        let expectedAccessibilityLabel = "New space detected"
        tester.waitForTappableView(withAccessibilityLabel: expectedAccessibilityLabel)
        tester.tapView(withAccessibilityLabel: "OK")
        tester.waitForAbsenceOfView(withAccessibilityLabel: expectedAccessibilityLabel)

        tester.waitForView(withAccessibilityLabel: "Fetch draft content")
    }

    private func getAllAccessibilityLabel(_ viewRoot: UIView) -> [String] {
        var array = [String]()
        for view in viewRoot.subviews {
            if let lbl = view.accessibilityLabel {
                array += [lbl]
            }

            array += getAllAccessibilityLabel(view)
        }

        return array
    }

    private func getAllAccessibilityLabelInWindows() -> [String] {
        var labelArray = [String]()
        for  window in UIApplication.shared.windows {
            labelArray += self.getAllAccessibilityLabel(window)
        }

        return labelArray
    }

}

extension XCTestCase {

    func wait(for duration: TimeInterval) {
        let waitExpectation = expectation(description: "Waiting")

        let when = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: when) {
            waitExpectation.fulfill()
        }

        // We use a buffer here to avoid flakiness with Timer on CI
        waitForExpectations(timeout: duration + 0.5)
    }
}
