
import Foundation
import UIKit

class LoadingTableViewCell: UITableViewCell, CellConfigurable {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    func configure(item: Any?) {
        activityIndicatorView.startAnimating()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicatorView.startAnimating()
    }
}
