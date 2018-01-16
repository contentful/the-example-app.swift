
import Foundation
import UIKit

class LayoutCopyDefaultTableViewCell: UITableViewCell, CellConfigurable {

    var didTapCallToActionButton: (() -> Void)?

    func configure(item: LayoutCopy) {
        if let urlString = item.ctaLink, let url = URL(string: urlString) {
            didTapCallToActionButton = {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

        titleLabel.text = item.headline
        copyLabel.text = item.copy
        callToActionButton.setTitle(item.ctaTitle, for: .normal)
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = .black
        }
    }

    @IBOutlet weak var copyLabel: UILabel! {
        didSet {
            copyLabel.textColor = .black
            copyLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .thin)
        }
    }

    @IBOutlet weak var callToActionButton: UIButton! {
        didSet {
            callToActionButton.layer.cornerRadius = 8.0
            callToActionButton.clipsToBounds = true
        }
    }

    @IBAction func callToActionButtonAction(_ sender: Any) {
        didTapCallToActionButton?()
    }

    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 15.0
            containerView.layer.borderColor = UIColor.darkGray.cgColor
            containerView.layer.borderWidth = 2.0
            containerView.clipsToBounds = true
        }
    }
}
