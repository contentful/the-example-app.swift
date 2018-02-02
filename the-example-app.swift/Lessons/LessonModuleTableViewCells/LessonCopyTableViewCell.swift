
import Foundation
import UIKit
import markymark

class LessonCopyTableViewCell: UITableViewCell, CellConfigurable, UITextViewDelegate {

    typealias ItemType = LessonCopy

    func configure(item: LessonCopy) {
        let attributedText = Markdown.attributedMarkdownText(text: item.copy, font: copyFont)
        copyTextView.attributedText = attributedText
        copyTextView.sizeToFit()
    }

    func resetAllContent() {
        copyTextView.text = ""
    }

    var copyFont: UIFont {
        return UIFont.systemFont(ofSize: 16.0, weight: .light)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBOutlet weak var copyTextView: UITextView! {
        didSet {
            copyTextView.delegate = self
        }
    }

    // MARK: UITextViewDelegate

    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
}
