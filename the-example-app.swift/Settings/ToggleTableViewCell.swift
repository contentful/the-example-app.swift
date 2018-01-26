
import Foundation
import UIKit

class ToggleTableViewCell: UITableViewCell, CellConfigurable {

    struct Model {
        let title: String
        let isSelected: Bool
    }

    typealias ItemType = Model

    func configure(item: Model) {
        toggleTextLabel.text = item.title
        accessoryType = item.isSelected ? .checkmark : .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        accessoryView?.isHidden = !selected
    }

    @IBOutlet weak var toggleTextLabel: UILabel!
}
