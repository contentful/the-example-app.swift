
import Foundation
import UIKit

class CategoryCollectionViewCell: UICollectionViewCell, CellConfigurable {

    // MARK: Interface Builder

    @IBOutlet weak var label: UILabel! {
        didSet {
            label.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
            label.textColor = .darkGray
        }
    }

    @IBOutlet weak var selectionMarker: UIView! {
        didSet {
            selectionMarker.isHidden = true
        }
    }

    // MARK: CellInfo

    func configure(item: String) {
        label.text = item
    }

    func resetAllContent() {
        label.text = nil
    }

    // MARK: UICollectionViewCell

    override var isSelected: Bool {
        didSet {
            if isSelected {
                label.textColor = .blue
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.selectionMarker.isHidden = false
                }
            } else {
                label.textColor = .lightGray
                UIView.animate(withDuration: 0.3) { [weak self]  in
                    self?.selectionMarker.isHidden = true
                }

            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if isSelected {
                label.textColor = .blue
            } else {
                label.textColor = .lightGray
            }
        }
    }
}
