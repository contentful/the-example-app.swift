
import Foundation
import UIKit

class CategoryCollectionViewCell: UICollectionViewCell, CellConfigurable {

    // MARK: Interface Builder

    @IBOutlet weak var label: UILabel! {
        didSet {
            label.font = UIFont.boldSystemFont(ofSize: 11.0)
            label.textColor = UIColor(red: 0.2941117, green: 0.2941117, blue: 0.2941117, alpha: 1.0)
        }
    }

    // MARK: CellInfo

    func configure(item: String) {
        label.text = item.uppercased()
    }

    // MARK: UICollectionViewCell

    override var isSelected: Bool {
        didSet {
            if isSelected {
                label.textColor = UIColor(red: 0.341176, green: 0.341176, blue: 0.341176, alpha: 1.0)
                backgroundColor = .white
            } else {
                label.textColor = UIColor(red: 0.2941117, green: 0.2941117, blue: 0.2941117, alpha: 1.0)
                backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
            }
        }
    }

    // MARK: UIView

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
    }
}
