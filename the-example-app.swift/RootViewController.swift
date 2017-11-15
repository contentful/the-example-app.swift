//
//  ContainerViewController.swift
//  the-example-app.swift
//
//  Created by JP Wright on 14.11.17.
//  Copyright © 2017 Contentful. All rights reserved.
//

import Foundation
import UIKit

final class RootViewController: UIViewController {

    func set(viewController: UIViewController, completion: (() -> Void)? = nil) {

        // Remove last child view controller.
        if let childViewController = self.childViewControllers.first {
            childViewController.willMove(toParentViewController: nil)
            childViewController.view.removeFromSuperview()
            childViewController.removeFromParentViewController()
        }
        // Add new view controller.

        addChildViewController(viewController)
        view.addSubview(viewController.view)

        viewController.view.frame = view.frame
        viewController.didMove(toParentViewController: self)
        self.viewController = viewController

        completion?()
    }

    private var viewController: UIViewController!

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
