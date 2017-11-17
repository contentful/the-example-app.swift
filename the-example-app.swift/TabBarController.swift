//
//  TabBarController.swift
//  the-example-app.swift
//
//  Created by JP Wright on 14.11.17.
//  Copyright © 2017 Contentful. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {

    let serviceBus: ServiceBus

    init(serviceBus: ServiceBus) {
        self.serviceBus = serviceBus

        super.init(nibName: nil, bundle: nil)

        viewControllers = [
            UINavigationController(rootViewController: HomeViewController(contentfulService: serviceBus.contentfulService)),
            UINavigationController(rootViewController: CoursesViewController(serviceBus: serviceBus)),
            UINavigationController(rootViewController: SettingsViewController(serviceBus: serviceBus))
        ]
        selectedIndex = 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
