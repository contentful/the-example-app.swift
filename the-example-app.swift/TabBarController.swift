
import Foundation
import UIKit

protocol TabBarTabViewController {

    var tabItem: UITabBarItem { get }
}

class TabBarController: UITabBarController {

    let services: Services

    init(services: Services) {
        self.services = services

        super.init(nibName: nil, bundle: nil)

        let viewControllers: [UIViewController] = [
            TabBarNavigationController(rootViewController: HomeViewController(services: services), services: services),
            TabBarNavigationController(rootViewController: CoursesTableViewController(services: services), services: services),
            TabBarNavigationController(rootViewController: SettingsViewController.new(services: services), services: services)
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

    public func showCoursesViewController(then completion: ((CoursesTableViewController) -> Void)? = nil) {
        selectedIndex = 1
        let coursesViewController = (viewControllers![1] as! TabBarNavigationController).viewControllers.first as! CoursesTableViewController
        completion?(coursesViewController)
    }

    public func showSettingsViewController() {
        selectedIndex = 2
    }
}
