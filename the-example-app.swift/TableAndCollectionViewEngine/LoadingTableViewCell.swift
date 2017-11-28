
import Foundation
import UIKit

class LoadingTableViewCell: UITableViewCell, CellConfigurable {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    func configure(item: Any?) {}

    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicatorView.startAnimating()
    }
}
