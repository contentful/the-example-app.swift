
import Foundation
import UIKit

/// View controller that is always the root of the UIScreen.
final class RootViewController: UIViewController {

    func set(viewController: UIViewController, completion: (() -> Void)? = nil) {

        // Remove last child view controller.
        if let childViewController = self.children.first {
            childViewController.willMove(toParent: nil)
            childViewController.view.removeFromSuperview()
            childViewController.removeFromParent()
        }
        // Add new view controller.

        addChild(viewController)
        view.addSubview(viewController.view)

        viewController.view.frame = view.frame
        viewController.didMove(toParent: self)
        self.viewController = viewController

        completion?()
    }

    public var viewController: UIViewController!

    init() {
        super.init(nibName: nil, bundle: nil)
        definesPresentationContext = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = UIScreen.main.bounds
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.viewController.supportedInterfaceOrientations
    }
}
