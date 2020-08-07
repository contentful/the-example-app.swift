
import Foundation
import UIKit
import Contentful


class ErrorTableViewCell: UITableViewCell, CellConfigurable {

    struct Model {
        let error: Error
        let services: ApplicationServices
    }

    var didTapResetCredentialsButton: (() -> Void)?

    func configure(item: Model) {

        didTapResetCredentialsButton = {
            item.services.resetCredentialsAndResetLocaleIfNecessary()
        }
        
        if item.error is SDKError || item.error is APIError {

            errorTitleLabel.text = "somethingWentWrongLabel".localized(contentfulService: item.services.contentful)
            errorDetailsLabel.attributedText = attributedErrorMessageHeader(errorMessageKey: "",
                                                                            hintsKeys: ["contentModelChangedErrorHint", "draftOrPublishedErrorHint", "localeContentErrorHint"],
                                                                            fontSize: 14.0,
                                                                            contentfulService: item.services.contentful)

            resetCredentialsButton.setTitle("resetCredentialsLabel".localized(contentfulService: item.services.contentful), for: .normal)
            resetCredentialsButton.isHidden = false
            return
        } else if let error = item.error as? NoContentError {
            errorTitleLabel.text = error.headline
            errorDetailsLabel.attributedText = error.message

            resetCredentialsButton.setTitle("resetCredentialsLabel".localized(contentfulService: item.services.contentful), for: .normal)
            resetCredentialsButton.isHidden = false
            return
        }
        let error = item.error as NSError
        errorTitleLabel.text = "somethingWentWrongLabel".localized(contentfulService: item.services.contentful)
        errorDetailsLabel.text = error.localizedDescription
        resetCredentialsButton.isHidden = true
    }

    func resetAllContent() {
        errorTitleLabel.text = nil
        errorDetailsLabel.text = nil
        resetCredentialsButton.isHidden = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBAction func resetCredentialsButtonAction(_ sender: Any) {
        didTapResetCredentialsButton?()
    }

    @IBOutlet weak var errorTitleLabel: UILabel! {
        didSet {
            errorTitleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
        }
    }
    @IBOutlet weak var resetCredentialsButton: UIButton!
    @IBOutlet weak var errorDetailsLabel: UILabel!
}
