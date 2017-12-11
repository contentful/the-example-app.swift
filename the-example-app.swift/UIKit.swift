
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
