
import Foundation
import UIKit
import Contentful


class ErrorTableViewCell: UITableViewCell, CellConfigurable {


    func configure(item: ErrorTableViewDataSource.Model) {

        errorTitleLabel.text = "An error occurred"

        var errorMessage = ""

        if let apiError = item.error as? APIError {
            switch apiError.statusCode {
            case 400:
                errorDetailsLabel.text = "contentModelChangedErrorLabel".localized(contentfulService: item.contentfulService)
            case 401:
                errorDetailsLabel.text = "verifyCredentialsErrorLabel".localized(contentfulService: item.contentfulService)

            default:
                fatalError("Unhandled error from Contentful")
            }
            errorMessage.append("Request ID: " + apiError.requestId)
            errorMessage.append(apiError.message)

            retryActionButton.isHidden = item.contentfulService.isConnectedToDefaultSpace()
            retryActionButton.setTitle("resetCredentialsLabel".localized(contentfulService: item.contentfulService), for: .normal)
        } else {
            retryActionButton.isHidden = true
        }
        errorDetailsLabel.text = errorMessage
    }

    func resetAllContent() {
        errorTitleLabel.text = nil
        errorDetailsLabel.text = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var retryActionButton: UIButton!
    @IBOutlet weak var errorDetailsLabel: UILabel!
}
