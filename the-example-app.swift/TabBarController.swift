
import Foundation
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    let services: Services

    init(services: Services, viewControllers: [UIViewController]) {
        self.services = services

        super.init(nibName: nil, bundle: nil)

        self.viewControllers = viewControllers
        selectedIndex = 0
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //
    }

    private func configureSelectedViewControllerBarButtonItems() {
        guard let navigationController = self.selectedViewController as? NavigationController else { return }
//        navigationController.persistentRightBarButtonItem = self.nowPlayingButtonItem
//        navigationController.topViewController?.navigationItem.rightBarButtonItem = nil
//        let spacerButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        spacerButtonItem.width = 20
//        navigationController.topViewController?.navigationItem.rightBarButtonItems = [nowPlayingButtonItem, spacerButtonItem]
    }
}
