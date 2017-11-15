//
//  AppAppearance.swift
//  the-example-app.swift
//
//  Created by JP Wright on 14.11.17.
//  Copyright © 2017 Contentful. All rights reserved.
//

import Foundation
import UIKit

protocol AppAppearance {

    static func customizeAppearance()
}

extension UIApplication: AppAppearance {

    static func customizeAppearance() {
        UINavigationBar.customizeAppearance()
        UIBarButtonItem.customizeAppearance()
    }
}

extension UINavigationBar: AppAppearance {

    static func customizeAppearance() {
        appearance().barStyle = UIBarStyle.default
        appearance().tintColor = .white
    }
}

extension UIBarButtonItem: AppAppearance {
    static func customizeAppearance() {
        appearance().tintColor = .white
    }
}

extension UIColor {
    // Put custom colors here.
}
