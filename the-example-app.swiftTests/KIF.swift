
import Foundation
import KIF

// http://cleanswifter.com/writing-first-kif-test/
extension XCTestCase {

    var tester: KIFUITestActor {
        return tester()
    }

    var system: KIFSystemTestActor {
        return system()
    }

    var viewTester: KIFUIViewTestActor {
        return viewTester()
    }

    private func viewTester(file : String = #file, _ line: Int = #line) -> KIFUIViewTestActor {
        return KIFUIViewTestActor(file: file, line: line, delegate: self)
    }

    private func tester(_ file: String = #file, _ line: Int = #line) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }

    private func system(_ file: String = #file, _ line: Int = #line) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
}

extension KIFTestActor {

    var tester: KIFUITestActor {
        return tester()
    }

    var system: KIFSystemTestActor {
        return system()
    }

    private func tester(_ file: String = #file, _ line: Int = #line) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }

    private func system(_ file: String = #file, _ line: Int = #line) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
}

