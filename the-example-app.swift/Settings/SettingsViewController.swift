
import Foundation
import UIKit

class SettingsViewController: UIViewController {

    let contentful: Contentful

    init(services: Services) {
        self.contentful = services.contentful
        super.init(nibName: "SettingsView", bundle: nil)
        self.title = NSLocalizedString("Settings", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        editorialFeaturesSwitch.isOn = contentful.editorialFeaturesAreEnabled
        spaceIdTextField.text = contentful.spaceId
        deliveryAccessTokenTextField.text = contentful.deliveryAccessToken
        previewAccessTokenTextField.text = contentful.previewAccessToken
    }

    // MARK: Interface Builder

    @IBOutlet weak var spaceIdTextField: CredentialTextField!
    @IBOutlet weak var deliveryAccessTokenTextField: CredentialTextField!
    @IBOutlet weak var previewAccessTokenTextField: CredentialTextField!

    @IBOutlet weak var editorialFeaturesSwitch: UISwitch!

    @IBAction func didToggleEditorialFeatures(_ sender: Any) {
        contentful.enableEditorialFeatures(editorialFeaturesSwitch.isOn)
    }
    
    @IBOutlet weak var editorialFeaturesContainer: UIView! {
        didSet {
            editorialFeaturesContainer.layer.borderWidth = 1.0
            editorialFeaturesContainer.layer.borderColor = UIColor(red: 0.74, green: 0.73, blue: 0.76, alpha: 1.0).cgColor
        }
    }

    @IBOutlet weak var connectedSpaceInfoLabel: UILabel!

    @IBOutlet weak var connectedSpaceInfoContainer: UIView! {
        didSet {
            connectedSpaceInfoContainer.layer.borderWidth = 1.0
            connectedSpaceInfoContainer.layer.borderColor = UIColor(red: 0.74, green: 0.73, blue: 0.76, alpha: 1.0).cgColor
        }
    }

}
