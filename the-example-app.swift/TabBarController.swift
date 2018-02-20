
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
            TabBarNavigationController(rootViewController: HomeLayoutTableViewController(services: services), services: services),
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

    public func showSettingsViewController(credentialsError: CredentialsTester.Error? = nil) {
        selectedIndex = 2
        let settingsViewController = (viewControllers![2] as! TabBarNavigationController).viewControllers.first as! SettingsViewController
        settingsViewController.errors = credentialsError?.errors ?? [:]
        settingsViewController.showErrorHeader()
    }

    public func clearSettingsErrors() {
        let settingsViewController = (viewControllers![2] as! TabBarNavigationController).viewControllers.first as! SettingsViewController
        settingsViewController.resetErrors()
    }
}
