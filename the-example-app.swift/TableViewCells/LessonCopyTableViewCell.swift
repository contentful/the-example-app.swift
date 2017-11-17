
import Foundation
import UIKit
import markymark

class LessonCopyTableViewCell: UITableViewCell, TableViewCellModel {

    typealias ItemType = LessonCopy

    @IBOutlet weak var copyLabel: UILabel! {
        didSet {

        }
    }

    func configure(item: LessonCopy) {
        let markyMark = MarkyMark() { $0.setFlavor(ContentfulFlavor()) }
        let markdownItems = markyMark.parseMarkDown(item.copy)
        let styling = DefaultStyling()
        let config = MarkDownToAttributedStringConverterConfiguration(styling: styling)
        let converter = MarkDownConverter(configuration: config)
        let attributedText = converter.convert(markdownItems)
        copyLabel.attributedText = attributedText
    }
}
