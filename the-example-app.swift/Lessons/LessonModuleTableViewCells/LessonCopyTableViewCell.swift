
import Foundation
import UIKit
import markymark

class LessonCopyTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = LessonCopy

    @IBOutlet weak var copyLabel: UILabel! {
        didSet {
            copyLabel.accessibilityIdentifier = "Lesson Copy Label"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = false
        selectionStyle = .none
    }

    func configure(item: LessonCopy) {
        let attributedText = Markdown.attributedMarkdownText(text: item.copy, font: copyFont)
        copyLabel.attributedText = attributedText
    }

    var copyFont: UIFont {
        return UIFont.systemFont(ofSize: 12.0, weight: .light)
    }
}
