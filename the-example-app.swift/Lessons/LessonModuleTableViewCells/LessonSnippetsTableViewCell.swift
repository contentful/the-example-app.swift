
import Foundation
import UIKit
import markymark

class LessonSnippetsTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = LessonSnippets

    func configure(item: LessonSnippets) {
        let code = """
        ```
        \(item.swift)
        ```
        """

        // TODO: Dry
        let markyMark = MarkyMark() { $0.setFlavor(ContentfulFlavor()) }
        let markdownItems = markyMark.parseMarkDown(code)
        let styling = DefaultStyling()
        let config = MarkDownToAttributedStringConverterConfiguration(styling: styling)
        // Configure markymark to leverage the Contentful images API when encountering inline SVGs.
        config.addLayoutBlockBuilder(SVGAttributedStringBlockBuilder())

        let converter = MarkDownConverter(configuration: config)
        let attributedText = converter.convert(markdownItems)
        codeSnippetLabel.attributedText = attributedText
    }

    @IBOutlet weak var codeSnippetLabel: UILabel! {
        didSet {
            codeSnippetLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18.0, weight: .medium)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = false
        selectionStyle = .none
    }
}
