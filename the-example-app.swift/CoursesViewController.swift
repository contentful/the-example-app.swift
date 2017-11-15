//
//  CoursesViewController.swift
//  the-example-app.swift
//
//  Created by JP Wright on 14.11.17.
//  Copyright © 2017 Contentful. All rights reserved.
//

import Foundation
import UIKit
import Contentful

class CoursesViewController: UIViewController { // , UITableViewDataSource, UITableViewDelegate {

    let contentfulProvider: ContentfulProvider

//    func query() -> QueryOn<Course>{
//        return QueryOn<HomeLayout>.where(field: .slug, .equals("home"))
//    }

    init(serviceBus: ServiceBus) {
        self.contentfulProvider = serviceBus.contentfulProvider
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Courses", image: nil, selectedImage: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

