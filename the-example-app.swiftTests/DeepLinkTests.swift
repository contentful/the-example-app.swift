
@testable import the_example_app_swift
import XCTest
import Nimble
import KIF

class DeepLinkTests: KIFTestCase {

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
        UIApplication.shared.open(URL(string:  "the-example-app.swift://courses/hello-sdks/lessons/sdk-basics")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "SDK basics")
    }

    func testSettingsRoute() {
        UIApplication.shared.open(URL(string:  "the-example-app.swift://settings")!, options: [:], completionHandler: nil)

        tester.waitForTappableView(withAccessibilityLabel: "U.S. English")
        // Tapping will cause the system to scroll
        tester.tapView(withAccessibilityLabel: "API: Preview")
        tester.waitForTappableView(withAccessibilityLabel: "API: Preview")
    }

    func testInvalidRoute() {
        
    }
}
