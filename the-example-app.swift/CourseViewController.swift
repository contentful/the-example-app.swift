
import Foundation
import UIKit

class CourseViewController: UIViewController {

    var course: Course!
    var services: ServiceBus!

    static func viewController(for course: Course, services: ServiceBus) -> CourseViewController {
        let viewController = CourseViewController(nibName: String(describing: "CourseView"), bundle: nil)
        viewController.services = services
        viewController.course = course
        return viewController
    }

    @IBAction func didTapStartCourseButton(_ sender: Any) {
        guard let lesson = course.lessons?.first else {
            fatalError("TODO")
        }

        // TODO: Actually push a collection view controller.
        let lessonViewController = LessonViewController(contentfulService: services.contentfulService, lesson: lesson)
        navigationController?.pushViewController(lessonViewController, animated: true)
    }
    @IBOutlet weak var startCourseButton: UIButton! {
        didSet {
            // Set font etc here.
        }
    }
}
