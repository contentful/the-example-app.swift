
import Foundation
import UIKit
import Contentful
import Interstellar

@discardableResult internal func +=<K, V> (left: [K: V], right: [K: V]) -> [K: V] {
    var result = left
    right.forEach { (key, value) in result[key] = value }
    return result
}

@discardableResult internal func +<K, V> (left: [K: V], right: [K: V]) -> [K: V] {
    return left += right
}

struct CredentialsTester {

    struct Error: Swift.Error {
        var errors: [ErrorKey: String]
    }

    enum ErrorKey: String {
        case spaceId
        case deliveryAccessToken
        case previewAccessToken

        var hashValue: Int {
            return rawValue.hashValue
        }
    }

    static func testCredentials(credentials: ContentfulCredentials, services: Services) -> Result<ContentfulService> {

        let newContentfulService = ContentfulService(session: services.session,
                                                     credentials: credentials,
                                                     api: services.contentful.apiStateMachine.state,
                                                     editorialFeaturesEnabled: services.contentful.editorialFeaturesStateMachine.state)


        var errors = CredentialsTester.makeTestCalls(testContentfulService: newContentfulService, services: services)
        errors = errors + CredentialsTester.makeTestCalls(testContentfulService: newContentfulService, services: services, toPreviewAPI: true)

        // If there are no errors, assign a new service
        if errors.isEmpty {
            return Result.success(newContentfulService)
        } else {
            return Result.error(CredentialsTester.Error(errors: errors))
        }
    }

    // Blocking method to validate if credentials are valid
    private static func makeTestCalls(testContentfulService: ContentfulService,
                                      services: Services,
                                      toPreviewAPI: Bool = false) -> [ErrorKey: String] {

        let semaphore = DispatchSemaphore(value: 0)
        let client = toPreviewAPI ? testContentfulService.previewClient : testContentfulService.deliveryClient

        var errors = [ErrorKey: String]()

        client.fetchSpace { result in

            switch result {
            case .success:
                errors.removeValue(forKey: .spaceId)
                if toPreviewAPI {
                    errors.removeValue(forKey: .previewAccessToken)
                } else {
                    errors.removeValue(forKey: .deliveryAccessToken)
                }
            case .error(let error):
                if let error = error as? APIError {
                    if error.statusCode == 401 {
                        if toPreviewAPI {
                            errors[.previewAccessToken] = "previewKeyInvalidLabel".localized(contentfulService: services.contentful)
                        } else {
                            errors[.deliveryAccessToken] = "deliveryKeyInvalidLabel".localized(contentfulService: services.contentful)
                        }
                    }
                    if error.statusCode == 404 {
                        errors[.spaceId] = "spaceOrTokenInvalid".localized(contentfulService: services.contentful)
                    }
                }
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return errors
    }
}

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



    var errors = [CredentialsTester.ErrorKey: String]()

    func validateTextFor(textField: UITextField, errorKey: CredentialsTester.ErrorKey) {
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

            let testResults = CredentialsTester.testCredentials(credentials: newCredentials, services: services)

            switch testResults {
            case .success(let newContentfulService):
                services.contentful = newContentfulService
                print("Switched client")
                services.session.spaceCredentials = newCredentials
                services.session.persistCredentials()
                resetErrors()
            case .error(let error) :
                let error = error as! CredentialsTester.Error
                self.errors = self.errors + error.errors
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
