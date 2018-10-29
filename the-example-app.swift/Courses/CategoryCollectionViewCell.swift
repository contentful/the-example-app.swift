
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

    // In iOS 12/Xcode 10 the collection view cell width which was previously dynamically determined by the inner text broke.
    // This fixes it. Inspired by: https://github.com/Instagram/IGListKit/issues/497#issuecomment-280929408
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        // note: don't change the width
        newFrame.size.width = ceil(size.width)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
