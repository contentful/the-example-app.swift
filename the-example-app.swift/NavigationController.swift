
import Foundation
import UIKit

protocol CustomNavigable {

    var hasCustomToolbar: Bool { get }
}

class NavigationController: UINavigationController, UINavigationControllerDelegate {

    let services: Services

    init(rootViewController: UIViewController, services: Services, title: String?) {
        self.services = services
        super.init(nibName: nil, bundle: nil)


        viewControllers = [rootViewController]

        navigationItem.rightBarButtonItems = [
            APIToggleBarButtonItem(services: services),
            LocaleToggleBarButtonItem(services: services)
        ]

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
        viewController.navigationItem.rightBarButtonItems = [
            APIToggleBarButtonItem(services: services),
            LocaleToggleBarButtonItem(services: services)
        ]
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

