
import Foundation
import UIKit

protocol AppearanceCustomizable {

    static func customizeAppearance()
}

extension UIApplication: AppearanceCustomizable {

    static func customizeAppearance() {
        UITableView.customizeAppearance()
        UINavigationBar.customizeAppearance()
        UIBarButtonItem.customizeAppearance()
    }
}

extension UINavigationBar: AppearanceCustomizable {

    static func customizeAppearance() {
        appearance().barStyle = UIBarStyle.default
    }
}

extension UIBarButtonItem: AppearanceCustomizable {
    static func customizeAppearance() {
        appearance().tintColor = .blue
    }
}

extension UITableView: AppearanceCustomizable {

    static func customizeAppearance() {
        appearance().backgroundColor = .white
        appearance().indicatorStyle = .white
        appearance().separatorStyle = .none
        appearance().separatorColor = .black
    }
}

extension UIColor {
    // Put custom colors here.
}
