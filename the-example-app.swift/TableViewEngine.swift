
import Foundation
import UIKit

protocol ViewFactory {

    associatedtype ItemType

    func cell(for item: ItemType, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell

    func configure(_ cell: UITableViewCell, with item: ItemType, at indexPath: IndexPath)
}

struct TableViewCellFactory<CellType>: ViewFactory where CellType: UITableViewCell & TableViewCellModel {

    func cell(for item: CellType.ItemType, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CellType.self), for: indexPath)

        guard let myCell = cell as? CellType else {
            fatalError()
        }
        myCell.configure(item: item)
        return cell
    }

    func configure(_ cell: UITableViewCell, with item: CellType.ItemType, at indexPath: IndexPath) {
        (cell as! CellType).configure(item: item)
    }
}
