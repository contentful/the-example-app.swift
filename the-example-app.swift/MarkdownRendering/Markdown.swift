
import Foundation
import markymark

struct Markdown {

    static func attributedMarkdownText(text: String, font: UIFont) -> NSAttributedString {
        let markyMark = MarkyMark() { $0.setFlavor(ContentfulFlavor()) }
        let markdownItems = markyMark.parseMarkDown(text)
        let styling = DefaultStyling()
        let config = MarkDownToAttributedStringConverterConfiguration(styling: styling)
        // Configure markymark to leverage the Contentful images API when encountering inline SVGs.
        config.addLayoutBlockBuilder(SVGAttributedStringBlockBuilder())

        let converter = MarkDownConverter(configuration: config)
        let attributedText = converter.convert(markdownItems)

        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttributes([.font: font], range: range)
        return attributedText
    }
}
