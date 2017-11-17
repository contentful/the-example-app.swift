
import Foundation
import UIKit

class LoadingTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicatorView.startAnimating()
    }
}
