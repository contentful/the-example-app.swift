
import Foundation
import UIKit
import Contentful

class SettingsViewController: UITableViewController {

    var services: Services!

    static func new(services: Services) -> SettingsViewController {
        let settings = UIStoryboard.init(name: "SettingsViewController", bundle: nil).instantiateInitialViewController() as! SettingsViewController
        settings.services = services
        // TODO: Move to update method triggered on locale/api update.
        settings.title = "settingsLabel".localized(contentfulService: services.contentful)
        return settings
    }

    override func loadView() {
        super.loadView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha:1.0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save Settings", style: .plain, target: self, action: #selector(SettingsViewController.didTapSaveSettings(_:)))
        editorialFeaturesSwitch.isOn = services.contentful.editorialFeaturesAreEnabled

        // Populate current credentials in text fields.
        spaceIdTextField.text = services.contentful.spaceId
        deliveryAccessTokenTextField.text = services.contentful.deliveryAccessToken
        previewAccessTokenTextField.text = services.contentful.previewAccessToken

        let _ = services.contentful.client.fetchSpace().then { [unowned self] space in
            DispatchQueue.main.async {
                self.currentlyConnectedSpaceLabel.text = space.name + " (" + space.id + ")"
            }
        }
    }

    enum ErrorKey: String {
        case spaceId
        case deliveryAccessToken
        case previewAccessToken

        var hashValue: Int {
            return rawValue.hashValue
        }
    }

    var errors = [ErrorKey: String]()

    func validateTextFor(textField: UITextField, errorKey: ErrorKey) {
        if textField.text == nil || textField.text!.isEmpty {
            errors[errorKey] = "fieldIsRequiredLabel".localized(contentfulService: services.contentful)
        } else {
            errors.removeValue(forKey: errorKey)
        }
    }

    @objc func didTapSaveSettings(_ sender: Any) {

        validateTextFor(textField: spaceIdTextField, errorKey: .spaceId)
        validateTextFor(textField: deliveryAccessTokenTextField, errorKey: .deliveryAccessToken)
        validateTextFor(textField: previewAccessTokenTextField, errorKey: .previewAccessToken)

        guard errors.count == 0 else {
            showErrorHeader()
            return
        }
        
        if let newSpaceId = spaceIdTextField.text,
            let newDeliveryAccessToken = deliveryAccessTokenTextField.text,
            let newPreviewAccessToken = previewAccessTokenTextField.text {

            let newCredentials = ContentfulCredentials(spaceId: newSpaceId,
                                                       deliveryAPIAccessToken: newDeliveryAccessToken,
                                                       previewAPIAccessToken: newPreviewAccessToken)

            let newContentfulService = ContentfulService(session: services.session,
                                                         credentials: newCredentials,
                                                         api: services.contentful.apiStateMachine.state,
                                                         editorialFeaturesEnabled: services.contentful.editorialFeaturesStateMachine.state)

            makeTestCalls(contentfulService: newContentfulService)
            makeTestCalls(contentfulService: newContentfulService, toPreviewAPI: true)
            // If there are no errors, assign a new service
            if errors.isEmpty {
                services.contentful = newContentfulService
                print("Switched client")
                services.session.spaceCredentials = newCredentials
                services.session.persistCredentials()
                resetErrors()
            } else {
                showErrorHeader()
            }
        }
    }

    func resetErrors() {
        errors = [:]
    }

    func showErrorHeader() {
        DispatchQueue.main.async { [unowned self] in

            var errorMessages = [String]()
            for (_, errorMessage) in self.errors {
                errorMessages.append(errorMessage)
            }

            let settingsErrorHeader = UINib(nibName: "SettingsErrorHeader", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SettingsErrorHeader
            settingsErrorHeader.configure(errorMessages: errorMessages)

            self.tableView.beginUpdates()
            self.tableView.tableHeaderView = settingsErrorHeader
            self.tableView.layoutTableHeaderView()
            self.tableView.endUpdates()
        }
    }

    // Blocking method to validate if credentials are valid
    func makeTestCalls(contentfulService: ContentfulService, toPreviewAPI: Bool = false) {
        let semaphore = DispatchSemaphore(value: 0)
        let client = toPreviewAPI ? contentfulService.previewClient : contentfulService.deliveryClient
        client.fetchSpace { [unowned self] result in

            switch result {
            case .success:
                self.errors.removeValue(forKey: .spaceId)
                if toPreviewAPI {
                    self.errors.removeValue(forKey: .previewAccessToken)
                } else {
                    self.errors.removeValue(forKey: .deliveryAccessToken)
                }
            case .error(let error):
                if let error = error as? APIError {
                    if error.statusCode == 401 {
                        if toPreviewAPI {
                            self.errors[.previewAccessToken] = "previewKeyInvalidLabel".localized(contentfulService: self.services.contentful)
                        } else {
                            self.errors[.deliveryAccessToken] = "deliveryKeyInvalidLabel".localized(contentfulService: self.services.contentful)
                        }
                    }
                    if error.statusCode == 404 {
                        self.errors[.spaceId] = "spaceOrTokenInvalid".localized(contentfulService: self.services.contentful)
                    }
                }
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    @IBOutlet weak var connectedSpaceCell: UITableViewCell!

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell === connectedSpaceCell {
            let connectedSpaceViewController = ConnectedSpaceViewController.new(services: services)
            navigationController?.pushViewController(connectedSpaceViewController, animated: true)
        }
    }


    // MARK: Interface Builder

    @IBOutlet weak var spaceIdDescriptionLabel: UILabel! {
        didSet {
            spaceIdDescriptionLabel.text = "spaceIdLabel".localized(contentfulService: services.contentful)
        }
    }

    @IBOutlet weak var deliveryAccessTokenDescriptionLabel: UILabel! {
        didSet {
            deliveryAccessTokenDescriptionLabel.text = "cdaAccessTokenLabel".localized(contentfulService: services.contentful)
        }
    }

    @IBOutlet weak var previewAccessTokenDescriptionLabel: UILabel! {
        didSet {
            previewAccessTokenDescriptionLabel.text = "cpaAccessTokenLabel".localized(contentfulService: services.contentful)
        }
    }

    @IBOutlet weak var spaceIdTextField: CredentialTextField!
    @IBOutlet weak var deliveryAccessTokenTextField: CredentialTextField!
    @IBOutlet weak var previewAccessTokenTextField: CredentialTextField!

    @IBOutlet weak var editorialFeaturesSwitch: UISwitch!
    @IBAction func didToggleEditorialFeatures(_ sender: Any) {
        services.contentful.enableEditorialFeatures(editorialFeaturesSwitch.isOn)
    }
    @IBOutlet weak var currentlyConnectedSpaceLabel: UILabel!
}


extension UITableView {

    func layoutTableHeaderView() {

        guard let headerView = tableHeaderView else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let headerSize = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let height = headerSize.height
        var frame = headerView.frame

        frame.size.height = height
        headerView.frame = frame

        headerView.translatesAutoresizingMaskIntoConstraints = true
        tableHeaderView = headerView
    }
}
