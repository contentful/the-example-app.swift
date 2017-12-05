
import Foundation
import XCTest
import Nimble


// Inspired by: https://blog.branch.io/ui-testing-universal-links-in-xcode-9/
class DeepLinkTests: XCTestCase {

    let app = XCUIApplication(bundleIdentifier: "the-example-app.swift")


    override func setUp() {
        super.setUp()
        app.activate()
        XCUIApplication.safari.activate()
    }

    override func tearDown() {
        super.tearDown()
        app.terminate()
    }

    func testBaseRoute() {
        XCUIApplication.safari.open(urlString: "the-example-app.swift://")

        expect(self.app.label).to(equal("the-example-app.swift"))
    }

    func testCoursesRoute() {
        XCUIApplication.safari.open(urlString: "the-example-app.swift://courses")

        // Test that there are three course cells and one cell for the category selection.
        expect(self.app.tables.firstMatch.cells.count).to(equal(4))
        expect(self.app.staticTexts["How the content of the example app is modelled"].exists).to(be(true))
    }

    func testSpecificCourseRoute() {
        XCUIApplication.safari.open(urlString: "the-example-app.swift://courses/how-the-content-of-the-example-app-is-modelled")

        sleep(1)
        // Test that there are three course cells and one cell for the category selection.  
        expect(self.app.tables.firstMatch.cells.count).to(equal(4))
        expect(self.app.staticTexts["How the content of the example app is modelled"].exists).to(be(true))
        expect(self.app.staticTexts["Lessons"].exists).to(be(true))

        expect(self.app.staticTexts["Field validation"].exists).to(be(true))
    }

    func testLessonRoute() {
        XCUIApplication.safari.open(urlString: "the-example-app.swift://courses/how-the-content-of-the-example-app-is-modelled/lessons/content-modules")

        let predicate = NSPredicate(format: "label CONTAINS 'As previously stated, you can use (reference) fields to create relationships between content types.'")
        let label = app.staticTexts.element(matching: predicate)
        expect(label.exists).to(be(true))
    }
//
//    func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5, file: String = #file, line: UInt = #line) {
//        let existsPredicate = NSPredicate(format: "exists == true")
//
//        expectation(for: existsPredicate,
//                    evaluatedWith: element, handler: nil)
//
//        waitForExpectations(timeout: timeout) { error in
//            if error != nil {
//                let message = "Failed to find \(element) after \(timeout) seconds."
//                self.recordFailure(withDescription: message, inFile: file, atLine: Int(line), expected: true)
//            }
//        }
//    }
}

extension XCUIApplication {

    static var safari: XCUIApplication = {
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        return safari
    }()

    func open(urlString: String) {
        buttons["URL"].tap()

        typeText(urlString)
        buttons["Go"].tap()
        buttons["Open"].tap()
    }
}
