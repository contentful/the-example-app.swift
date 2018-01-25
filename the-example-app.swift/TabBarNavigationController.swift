
import Foundation
import UIKit

protocol CustomNavigable {

    var hasCustomToolbar: Bool { get }

    var prefersLargeTitles: Bool { get }
}

struct NavBarButton {
    let persistsOnPush: Bool

    let button: UIBarButtonItem
}

class TabBarNavigationController: UINavigationController, UINavigationControllerDelegate {

    let services: Services

    let navBarButton: NavBarButton?

    init(rootViewController: UIViewController & TabBarTabViewController,
         services: Services,
         navBarButton: NavBarButton? = nil) {

        self.services = services
        self.navBarButton = navBarButton

        super.init(nibName: nil, bundle: nil)

        viewControllers = [rootViewController]

        services.contentful.stateMachine.addTransitionObservationAndObserveInitialState { [unowned self] _ in
            // Use an observation to update the locale of the tab bar item when it's toggled.
            self.tabBarItem = rootViewController.tabItem
        }

        if let navBarButton = navBarButton {
            navigationItem.rightBarButtonItem = navBarButton.button
        }

        navigationBar.prefersLargeTitles = true

        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateToolbar(for viewController: UIViewController) {
        // Reset.
        isToolbarHidden = true

        if let navigableViewController = viewController as? CustomNavigable {
            isToolbarHidden = navigableViewController.hasCustomToolbar == false
            tabBarController?.tabBar.isHidden = navigableViewController.hasCustomToolbar
            navigationBar.prefersLargeTitles = navigableViewController.prefersLargeTitles
        }
    }

    func setNavigationItems(forViewController viewController: UIViewController) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        if let navBarButton = navBarButton {
            viewController.navigationItem.rightBarButtonItem = navBarButton.button
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let topViewController = topViewController else { return }
        updateToolbar(for: topViewController)
    }

    // MARK: UINavigationController

    override var viewControllers: [UIViewController] {
        didSet {
            for viewController in viewControllers {
                setNavigationItems(forViewController: viewController)
            }
        }
    }

    // MARK: UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        setNavigationItems(forViewController: viewController)
        updateToolbar(for: viewController)
    }
}


