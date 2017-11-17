//
//  SettingsViewController.swift
//  the-example-app.swift
//
//  Created by JP Wright on 14.11.17.
//  Copyright © 2017 Contentful. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    let contentfulService: ContentfulService

    //    func query() -> QueryOn<Course>{
    //        return QueryOn<HomeLayout>.where(field: .slug, .equals("home"))
    //    }

    init(serviceBus: ServiceBus) {
        self.contentfulService = serviceBus.contentfulService
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Settings", image: nil, selectedImage: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
