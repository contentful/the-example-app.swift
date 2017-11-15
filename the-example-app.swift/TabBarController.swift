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
            HomeViewController(contentfulProvider: serviceBus.contentfulProvider),
            CoursesViewController(serviceBus: serviceBus),
            SettingsViewController(serviceBus: serviceBus)
        ]
        selectedIndex = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
