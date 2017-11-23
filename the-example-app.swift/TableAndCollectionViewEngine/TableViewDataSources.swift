
import Foundation
import UIKit

class LoadingTableViewDataSource: NSObject, UITableViewDataSource {

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(indexPath.row == 0)
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LoadingTableViewCell.self), for: indexPath)
        return cell
    }
}



class ErrorTableViewDataSource: NSObject, UITableViewDataSource {

    init(error: Error) {

    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(indexPath.row == 0)
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ErrorTableViewCell.self), for: indexPath)
        return cell
    }
}

class ErrorTableViewCell: UITableViewCell {

}
