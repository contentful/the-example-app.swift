
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
