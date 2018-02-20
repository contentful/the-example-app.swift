
import Foundation
import UIKit
import Contentful


class ErrorTableViewCell: UITableViewCell, CellConfigurable {

    struct Model {
        let error: Error
        let contentfulService: ContentfulService
    }

    func configure(item: Model) {

        if let _ = item.error as? SDKError {

            errorTitleLabel.text = "somethingWentWrongLabel".localized(contentfulService: item.contentfulService)
            errorDetailsLabel.attributedText = attributedErrorMessageHeader(errorMessageKey: "",
                                                                            hintsKeys: ["contentModelChangedErrorHint", "draftOrPublishedErrorHint", "localeContentErrorHint"],
                                                                            fontSize: 14.0,
                                                                            contentfulService: item.contentfulService)

            retryActionButton.setTitle("resetCredentialsLabel".localized(contentfulService: item.contentfulService), for: .normal)
            retryActionButton.isHidden = false
        } else if let error = item.error as? NoContentError {


            errorTitleLabel.text = error.headline
            errorDetailsLabel.attributedText = error.message

            retryActionButton.setTitle("resetCredentialsLabel".localized(contentfulService: item.contentfulService), for: .normal)
            retryActionButton.isHidden = false
        } else {
            fatalError()
        }
    }

    func resetAllContent() {
        errorTitleLabel.text = nil
        errorDetailsLabel.text = nil
        retryActionButton.isHidden = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var retryActionButton: UIButton!
    @IBOutlet weak var errorDetailsLabel: UILabel!
}
