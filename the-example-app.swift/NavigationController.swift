
import Foundation
import UIKit

protocol CustomNavigable {

    var hasCustomToolbar: Bool { get }
}

struct NavigationItems {
    let persistsOnPush: Bool

    let rightBarButtonItems: [UIBarButtonItem]
}

class NavigationController: UINavigationController, UINavigationControllerDelegate {

    let services: Services

    let navigationItems: NavigationItems?

    init(rootViewController: UIViewController, services: Services, title: String?, navigationItems: NavigationItems? = nil) {
        self.services = services
        self.navigationItems = navigationItems
        super.init(nibName: nil, bundle: nil)

        viewControllers = [rootViewController]

        if let navigationItems = navigationItems {
            navigationItem.rightBarButtonItems = navigationItems.rightBarButtonItems
        }

        navigationBar.prefersLargeTitles = true

        if let title = title {
            tabBarItem.title = title
        }
        delegate = self
    }

    override var viewControllers: [UIViewController] {
        didSet {
            for viewController in viewControllers {
                setNavigationItems(forViewController: viewController)
            }
        }
    }

    func setNavigationItems(forViewController viewController: UIViewController) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        if let navigationItems = navigationItems {
            viewController.navigationItem.rightBarButtonItems = navigationItems.rightBarButtonItems
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        setNavigationItems(forViewController: viewController)

        if let navigableViewController = viewController as? CustomNavigable, navigableViewController.hasCustomToolbar == true {

            isToolbarHidden = false

        } else {
            isToolbarHidden = true
        }
    }
}

class APIToggleBarButtonItem: UIBarButtonItem {

    let contentful: Contentful

    init(services: Services) {
        self.contentful = services.contentful
        super.init()

        title = contentful.apiBarButtonTitle()
        style = .plain
        target = self
        action = #selector(APIToggleBarButtonItem.didTap(_:))
    }

    @objc func didTap(_ sender: Any) {
        contentful.toggleAPI()
        title = contentful.apiBarButtonTitle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LocaleToggleBarButtonItem: UIBarButtonItem {

    let contentful: Contentful

    init(services: Services) {
        self.contentful = services.contentful
        
        super.init()
        title = contentful.localeBarButtonTitle()
        style = .plain
        target = self
        action = #selector(LocaleToggleBarButtonItem.didTap(_:))
    }

    @objc func didTap(_ sender: Any) {
        contentful.toggleLocale()
        title = contentful.localeBarButtonTitle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

