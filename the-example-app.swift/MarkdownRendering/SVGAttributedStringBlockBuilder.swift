

import Foundation
import markymark
import Contentful

class SVGAttributedStringBlockBuilder: LayoutBlockBuilder<NSMutableAttributedString> {

    // MARK: LayoutBuilder

    override func relatedMarkDownItemType() -> MarkDownItem.Type {
        return ImageBlockMarkDownItem.self
    }

    override func build(_ markDownItem: MarkDownItem,
                        asPartOfConverter converter: MarkDownConverter<NSMutableAttributedString>,
                        styling: ItemStyling) -> NSMutableAttributedString {

        let imageMarkDownItem = markDownItem as! ImageMarkDownItem

        let attachment = TextAttachment()

        if let image = UIImage(named: imageMarkDownItem.file) {
            attachment.image = image
        } else if imageMarkDownItem.file.hasSuffix(".svg"), let url = try? imageMarkDownItem.file.url(with: [.formatAs(.jpg(withQuality: .asPercent(100)))]) {
            // Convert SVGs to JPGs via the Contentful Images API.
            let data = try? Data(contentsOf: url)

            if let data = data, let image = UIImage(data: data) {
                attachment.image = image
            }
        } else if let url = try? imageMarkDownItem.file.url() {
            let data = try? Data(contentsOf: url)

            if let data = data, let image = UIImage(data: data) {
                attachment.image = image
            }
        }

        if attachment.image == nil {
            return NSMutableAttributedString()
        }

        let mutableAttributedString = NSAttributedString(attachment: attachment)

        return mutableAttributedString as! NSMutableAttributedString
    }
}
