
import Foundation
import UIKit
import markymark

class LessonSnippetsTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = LessonSnippets

    func configure(item: LessonSnippets) {
        populateCodeSnippet(code: item.swift)
    }

    func populateCodeSnippet(code: String) {
        let snippet = """
        ```
        \(code)

        ```
        """
        let markyMark = MarkyMark() { $0.setFlavor(ContentfulFlavor()) }
        let markdownItems = markyMark.parseMarkDown(snippet)
        let styling = DefaultStyling()
        let config = MarkDownToAttributedStringConverterConfiguration(styling: styling)
        // Configure markymark to leverage the Contentful images API when encountering inline SVGs.
        config.addLayoutBlockBuilder(SVGAttributedStringBlockBuilder())

        let converter = MarkDownConverter(configuration: config)
        let attributedText = converter.convert(markdownItems)
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttributes([.font: snippetFont], range: range)
        codeSnippetLabel.attributedText = attributedText
    }

    @IBOutlet weak var codeSnippetLabel: UILabel! {
        didSet {
            codeSnippetLabel.font = snippetFont
        }
    }

     var snippetFont: UIFont {
        return UIFont.sfMonoFont(ofSize: 12.0, weight: .medium)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = false
        selectionStyle = .none
    }
}
