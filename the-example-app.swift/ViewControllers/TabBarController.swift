
import Foundation
import UIKit

protocol TabBarTabViewController {

    var tabItem: UITabBarItem { get }
}

class TabBarController: UITabBarController {

    let services: ApplicationServices

    init(services: ApplicationServices) {
        self.services = services

        super.init(nibName: nil, bundle: nil)

        let refreshButton = UIBarButtonItem(image: UIImage(named: "navbar-icon-refresh"), style: .plain, target: self, action: #selector(TabBarController.refresh))
        let navBarButton = NavBarButton(persistsOnPush: true, button: refreshButton)

        let viewControllers: [UIViewController] = [
            TabBarNavigationController(rootViewController: HomeLayoutTableViewController(services: services), services: services, navBarButton: navBarButton),
            TabBarNavigationController(rootViewController: CoursesTableViewController(services: services), services: services, navBarButton: navBarButton),
            TabBarNavigationController(rootViewController: SettingsViewController.new(services: services), services: services)
        ]

        self.viewControllers = viewControllers
        selectedIndex = 0
    }

    @objc func refresh() {
        services.contentful.stateMachine.triggerObservations()
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
        (viewControllers![1] as! TabBarNavigationController).popToRootViewController(animated: false)
        completion?(coursesViewController)
    }

    public func showSettingsViewController(credentialsError: CredentialsTester.Error? = nil) {
        selectedIndex = 2
        guard let credentialsError = credentialsError else { return }
        let settingsViewController = (viewControllers![2] as! TabBarNavigationController).viewControllers.first as! SettingsViewController
        settingsViewController.showErrorHeader(credentialsError: credentialsError)
    }

    public func clearSettingsErrors() {
        let settingsViewController = (viewControllers![2] as! TabBarNavigationController).viewControllers.first as! SettingsViewController
        settingsViewController.resetErrors()
    }
}
