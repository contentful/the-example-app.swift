
import Foundation
import UIKit

class LoadingTableViewDataSource: NSObject, UITableViewDataSource {

    let cellFactory = TableViewCellFactory<LoadingTableViewCell>()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(indexPath.row == 0)
        let cell = cellFactory.cell(for: nil, in: tableView, at: indexPath)
        return cell
    }
}



class ErrorTableViewDataSource: NSObject, UITableViewDataSource {

    let model: ErrorTableViewCell.Model

    let cellFactory = TableViewCellFactory<ErrorTableViewCell>()

    init(model: ErrorTableViewCell.Model) {
        self.model = model
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(indexPath.row == 0)
        let cell = cellFactory.cell(for: model, in: tableView, at: indexPath)
        return cell
    }
}
