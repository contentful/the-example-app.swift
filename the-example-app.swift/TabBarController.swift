
import Foundation
import UIKit

class TabBarController: UITabBarController {

    let services: Services

    init(services: Services) {
        self.services = services

        super.init(nibName: nil, bundle: nil)

        let viewControllers: [UIViewController] = [
            NavigationController(rootViewController: HomeViewController(services: services), services: services, title: "Home"),
            NavigationController(rootViewController: CoursesViewController(services: services), services: services, title: "Courses"),
            NavigationController(rootViewController: SettingsViewController(services: services), services: services, title: "Settings")
        ]

        self.viewControllers = viewControllers
        selectedIndex = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func showHomeViewController() {
        selectedIndex = 0
    }

    public func showCoursesViewController(then completion: ((CoursesViewController) -> Void)? = nil) {
        selectedIndex = 1
        let coursesViewController = (viewControllers![1] as! NavigationController).viewControllers.first as! CoursesViewController
        completion?(coursesViewController)
    }

    public func showSettingsViewController() {
        selectedIndex = 2
    }
}
