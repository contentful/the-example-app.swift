
import Foundation
import UIKit

protocol CellConfigurable {

    associatedtype ItemType

    func configure(item: ItemType)
}

protocol CellFactory {

    associatedtype ItemType
    associatedtype CellType: CellConfigurable
    associatedtype ViewType

    func cell(for item: ItemType, in view: ViewType, at indexPath: IndexPath) -> CellType

    func configure(_ cell: CellType, with item: ItemType, at indexPath: IndexPath)
}

extension CellFactory {

    func configure(_ cell: CellType, with item: CellType.ItemType, at indexPath: IndexPath) {
        cell.configure(item: item)
    }
}

struct TableViewCellFactory<CellType>: CellFactory where CellType: CellConfigurable & UITableViewCell {

    typealias ViewType = UITableView

    func cell(for item: CellType.ItemType, in view: UITableView, at indexPath: IndexPath) -> CellType {
        let tableView = view
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CellType.self), for: indexPath)

        guard let myCell = cell as? CellType else {
            fatalError()
        }
        myCell.configure(item: item)
        return cell as! CellType
    }
}


struct CollectionViewCellFactory<CellType>: CellFactory where CellType: CellConfigurable & UICollectionViewCell {

    typealias ViewType = UICollectionView

    func cell(for item: CellType.ItemType, in view: UICollectionView, at indexPath: IndexPath) -> CellType {
        let collectionView = view
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CellType.self), for: indexPath)

        guard let myCell = cell as? CellType else {
            fatalError()
        }
        myCell.configure(item: item)
        return cell as! CellType
    }
}
