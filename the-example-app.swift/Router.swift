/**
 * Todo: this class should handle deep links.
 */

import Foundation
import UIKit

final class Router {

    let rootViewController: RootViewController

    let serviceBus: ServiceBus

    init(serviceBus: ServiceBus) {
        self.serviceBus = serviceBus
        self.rootViewController = RootViewController()

        // Show view controllers.
        showTabBarController()
    }

    func showTabBarController() {
        let tabBarController = TabBarController(serviceBus: serviceBus)
        self.rootViewController.set(viewController: tabBarController)
    }


    // MARK: Routing

    func handleDeepLink() {
        // Update session credentials
    }
}
