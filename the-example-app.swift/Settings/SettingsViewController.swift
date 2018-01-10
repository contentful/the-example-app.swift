
import Foundation
import UIKit
import Contentful

class SettingsViewController: UIViewController {

    let services: Services

    init(services: Services) {
        self.services = services
        super.init(nibName: "SettingsView", bundle: nil)
        self.title = NSLocalizedString("Settings", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save Settings", style: .plain, target: self, action: #selector(SettingsViewController.didTapSaveSettings(_:)))
        editorialFeaturesSwitch.isOn = services.contentful.editorialFeaturesAreEnabled
        spaceIdTextField.text = services.contentful.spaceId
        deliveryAccessTokenTextField.text = services.contentful.deliveryAccessToken
        previewAccessTokenTextField.text = services.contentful.previewAccessToken
    }


    var spaceIdError: String?
    var deliveryAccessTokenError: String?
    var previewAccessTokenError: String?

    @objc func didTapSaveSettings(_ sender: Any) {

        if spaceIdTextField.text == nil || spaceIdTextField.text!.isEmpty == false {
            spaceIdError = NSLocalizedString("fieldIsRequiredLabel", comment: "")
        }
        if deliveryAccessTokenTextField.text == nil || deliveryAccessTokenTextField.text!.isEmpty == true {
            deliveryAccessTokenError = NSLocalizedString("fieldIsRequiredLabel", comment: "")
        }
        if previewAccessTokenTextField.text == nil || previewAccessTokenTextField.text!.isEmpty == true {
            previewAccessTokenError = NSLocalizedString("fieldIsRequiredLabel", comment: "")
        }

        if let newSpaceId = spaceIdTextField.text,
            let newDeliveryAccessToken = deliveryAccessTokenTextField.text,
            let newPreviewAccessToken = previewAccessTokenTextField.text {

            let newCredentials = ContentfulCredentials(spaceId: newSpaceId,
                                                       deliveryAPIAccessToken: newDeliveryAccessToken,
                                                       previewAPIAccessToken: newPreviewAccessToken)

            let newContentfulService = ContentfulService(session: services.session,
                                                  credentials: newCredentials,
                                                  state: services.contentful.apiStateMachine.state)

            makeTestCalls(contentfulService: newContentfulService)
            makeTestCalls(contentfulService: newContentfulService, toPreviewAPI: true)
            // If there are no errors, assign a new service
            if spaceIdError == nil && deliveryAccessTokenError == nil && previewAccessTokenError == nil {
                services.contentful = newContentfulService
                print("Switched client")
                services.session.spaceCredentials = newCredentials
                services.session.persistCredentials()
            }
        }
    }

    // Blocking method to validate if credentials are valid
    func makeTestCalls(contentfulService: ContentfulService, toPreviewAPI: Bool = false) {
        let semaphore = DispatchSemaphore(value: 0)
        let client = toPreviewAPI ? contentfulService.previewClient : contentfulService.deliveryClient
        client.fetchSpace { [weak self] result in
            switch result {
            case .success:
                self?.spaceIdError = nil
                if toPreviewAPI {
                    self?.previewAccessTokenError = nil
                } else {
                    self?.deliveryAccessTokenError = nil
                }
            case .error(let error):
                if let error = error as? APIError {
                    if error.statusCode == 401 {
                        if toPreviewAPI {
                            self?.previewAccessTokenError = NSLocalizedString("previewKeyInvalidLabel", comment: "")
                            // TODO:
                        } else {
                            self?.deliveryAccessTokenError = NSLocalizedString("deliveryKeyInvalidLabel", comment: "")
                            // TODO: Update UI
                        }
                    }
                    if error.statusCode == 404 {
                        self?.spaceIdError = NSLocalizedString("spaceOrTokenInvalid", comment: "")
                        // TODO:
                    }
                }
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }

    // MARK: Interface Builder

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var spaceIdTextField: CredentialTextField!
    @IBOutlet weak var deliveryAccessTokenTextField: CredentialTextField!
    @IBOutlet weak var previewAccessTokenTextField: CredentialTextField!

    @IBOutlet weak var editorialFeaturesSwitch: UISwitch!

    @IBAction func didToggleEditorialFeatures(_ sender: Any) {
        services.contentful.enableEditorialFeatures(editorialFeaturesSwitch.isOn)
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
