
import Foundation
import UIKit

class TabBarController: UITabBarController {

    let services: Services

    init(services: Services) {
        self.services = services

        super.init(nibName: nil, bundle: nil)

        let rightToggleBarButtonItems = [
            APIToggleBarButtonItem(services: services),
            LocaleToggleBarButtonItem(services: services)
        ]
        let toggleNavigationItems = NavigationItems(persistsOnPush: true, rightBarButtonItems: rightToggleBarButtonItems)
        let viewControllers: [UIViewController] = [
            NavigationController(rootViewController: HomeViewController(services: services), services: services, title: "Home", navigationItems: toggleNavigationItems),
            NavigationController(rootViewController: CoursesViewController(services: services), services: services, title: "Courses", navigationItems: toggleNavigationItems),
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
