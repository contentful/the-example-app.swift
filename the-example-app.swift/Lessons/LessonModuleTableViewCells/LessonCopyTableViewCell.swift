
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
        let markyMark = MarkyMark() { $0.setFlavor(ContentfulFlavor()) }
        let markdownItems = markyMark.parseMarkDown(item.copy)
        let styling = DefaultStyling()
        let config = MarkDownToAttributedStringConverterConfiguration(styling: styling)
        // Configure markymark to leverage the Contentful images API when encountering inline SVGs.
        config.addLayoutBlockBuilder(SVGAttributedStringBlockBuilder())

        let converter = MarkDownConverter(configuration: config)
        let attributedText = converter.convert(markdownItems)
        copyLabel.attributedText = attributedText
    }
}
