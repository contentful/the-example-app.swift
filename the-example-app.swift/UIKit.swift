
import Foundation
import UIKit

extension UITableView {

    func register(_ type: UITableViewCell.Type) {
        let typeName = String(describing: type)
        register(type, forCellReuseIdentifier: typeName)

    }

    func registerNibFor(_ type: UITableViewCell.Type) {
        let typeName = String(describing: type)
        let nib = UINib(nibName: typeName, bundle: nil)
        register(nib, forCellReuseIdentifier: typeName)
    }
}

extension UICollectionView {
    
    func register(_ type: UIView.Type) {
        let typeName = String(describing: type)
        register(type, forCellWithReuseIdentifier: typeName)
    }

    func registerNibFor(_ type: UIView.Type) {
        let typeName = String(describing: type)
        let nib = UINib(nibName: typeName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: typeName)
    }
}

extension UIFont {

    static func sfMonoFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        switch weight {

        case .ultraLight:   return UIFont(name: "SFMono-Ultralight", size: size)!
        case .thin:         return UIFont(name: "SFMono-Thin", size: size)!
        case .light:        return UIFont(name: "SFMono-Light", size: size)!
        case .regular:      return UIFont(name: "SFMono-Regular", size: size)!
        case .medium:       return UIFont(name: "SFMono-Medium", size: size)!
        case .semibold:     return UIFont(name: "SFMono-Semibold", size: size)!
        case .heavy:        return UIFont(name: "SFMono-Heavy", size: size)!
        case .black:        return UIFont(name: "SFMono-Black", size: size)!
        // If something went wrong return the system font.
        default:            return UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
}

extension UITextView {

    func showDraftState() {
        text = "Draft".uppercased()
        backgroundColor = UIColor(red: 0.9, green: 0.68, blue: 0.09, alpha: 1.0)
        sizeToFit()
    }

    func showPendingChangesState() {
        text = "Pending changes".uppercased()
        backgroundColor = UIColor(red: 0.24, green: 0.5, blue: 0.81, alpha: 1.0)
        sizeToFit()
    }

    static let resourceStateInsets = UIEdgeInsets(top: 2.0, left: 4.0, bottom: 2.0, right: 4.0)
}

extension UIView {

    static func loadingOverlay(frame: CGRect) -> UIView {
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
        return view
    }
}
