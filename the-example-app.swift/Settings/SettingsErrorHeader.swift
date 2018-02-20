
import Foundation
import UIKit

class SettingsErrorHeader: UIView {

    func configure(errorMessages: [String]) {


        let errorsOccurredString = NSMutableAttributedString()

        if let image = UIImage(named: "settings-error-icon")  {
            let listenerAttachment = NSTextAttachment()
            listenerAttachment.image = image
            listenerAttachment.bounds = CGRect(origin: .zero, size: image.size)
            errorsOccurredString.append(NSAttributedString(attachment: listenerAttachment))
            errorsOccurredString.addAttribute(.baselineOffset, value: NSNumber(value: -5), range: NSRange(location: 0, length: errorsOccurredString.length))

        }
        let attributes: [NSAttributedStringKey: Any] = [
            .foregroundColor: UIColor(red: 0.8, green: 0.25, blue: 0.22, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 13.0, weight: .bold)
        ]
        errorsOccurredString.append(NSAttributedString(string: " Error(s) occurred:", attributes: attributes))
        errorsOccurredLabel.attributedText = errorsOccurredString

        let errorMessagesString = NSMutableAttributedString()

        for errorMessage in errorMessages {
            errorMessagesString.append(NSAttributedString(string: "• " + errorMessage, attributes: [.font: UIFont.systemFont(ofSize: 13.0, weight: .regular)]))
            errorMessagesString.append(NSAttributedString(string: "\n", attributes: [:]))
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.38
        errorMessagesString.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: errorMessagesString.length))
        errorMessagesLabel.attributedText = errorMessagesString

        // TODO:
        accessibilityLabel = errorMessagesString.string
    }
    
    @IBOutlet weak var errorMessagesLabel: UILabel! { didSet {
        errorMessagesLabel.textColor = UIColor(red: 0.8, green: 0.25, blue: 0.22, alpha: 1.0)
        }
    }

    @IBOutlet weak var errorsOccurredLabel: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
        errorMessagesLabel.preferredMaxLayoutWidth = errorMessagesLabel.frame.width
    }
}
