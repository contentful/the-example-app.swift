
import Foundation
import UIKit

class CourseViewController: UIViewController {

    var course: Course
    var services: Services

    init(course: Course, services: Services) {
        self.course = course
        self.services = services
        super.init(nibName: String(describing: "CourseView"), bundle: nil)
        self.hidesBottomBarWhenPushed = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func didTapStartCourseButton(_ sender: Any) {
        guard let lesson = course.lessons?.first else {
            fatalError("TODO")
        }

        let lessonViewController = LessonsCollectionViewController(course: course, services: services)
        navigationController?.pushViewController(lessonViewController, animated: true)
    }

    @IBOutlet weak var startCourseButton: UIButton! {
        didSet {
            // Set font etc here.
        }
    }

    // TODO: Should this be a tableView?
    
    // TODO: Show course overview here.
}
