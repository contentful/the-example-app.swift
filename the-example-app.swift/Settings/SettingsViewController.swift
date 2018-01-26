
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
                                                     api: services.contentful.stateMachine.state.api,
                                                     editorialFeaturesEnabled: services.contentful.stateMachine.state.editorialFeaturesEnabled)


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

class SettingsViewController: UITableViewController, TabBarTabViewController, UITextFieldDelegate, CustomNavigable {

    var tabItem: UITabBarItem {
        return UITabBarItem(title: "settingsLabel".localized(contentfulService: services.contentful),
                            image: UIImage(named: "tabbar-icon-settings"),
                            selectedImage: nil)
    }
    
    var services: Services!

    static func new(services: Services) -> SettingsViewController {
        let settings = UIStoryboard.init(name: "SettingsViewController", bundle: nil).instantiateInitialViewController() as! SettingsViewController
        settings.services = services
        return settings
    }

    // MARK: CustomNavigable

    var hasCustomToolbar: Bool {
        return false
    }

    var prefersLargeTitles: Bool {
        return true
    }

    override func loadView() {
        super.loadView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none

        tableView.registerNibFor(ToggleTableViewCell.self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.changeTextFieldText(_:)), name: .UITextFieldTextDidChange, object: nil)

        view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha:1.0)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save Settings", style: .plain, target: self, action: #selector(SettingsViewController.didTapSaveSettings(_:)))

        localizeTextsViaStateObservations()

        services.contentfulStateMachine.addTransitionObservationAndObserveInitialState { [unowned self] _ in
            self.updateFormFieldsWithCurrentSession()
        }
        for textField in [spaceIdTextField, deliveryAccessTokenTextField, previewAccessTokenTextField] {
            textField?.delegate = self
        }
    }

    func localizeTextsViaStateObservations() {
        // Update all text labels.
        services.contentful.stateMachine.addTransitionObservationAndObserveInitialState { [unowned self] _ in
            self.title = "settingsLabel".localized(contentfulService: self.services.contentful)

            self.localeDescriptionLabel.text = "localeQuestion".localized(contentfulService: self.services.contentful)
            self.apiDescriptionLabel.text = "apiSwitcherHelp".localized(contentfulService: self.services.contentful)

            self.connectedToSpaceLabel.text = "connectedToSpaceLabel".localized(contentfulService: self.services.contentful)
            self.overrideConfigLabel.text = "overrideConfigLabel".localized(contentfulService: self.services.contentful)

            self.spaceIdDescriptionLabel.text = "spaceIdLabel".localized(contentfulService: self.services.contentful)
            self.deliveryAccessTokenDescriptionLabel.text = "cdaAccessTokenLabel".localized(contentfulService: self.services.contentful)
            self.previewAccessTokenDescriptionLabel.text = "cpaAccessTokenLabel".localized(contentfulService: self.services.contentful)
            self.credentialsHelpTextLabel.text = "settingsIntroLabel".localized(contentfulService: self.services.contentful)

            self.enableEditorialFeaturesLabel.text = "enableEditorialFeaturesLabel".localized(contentfulService: self.services.contentful)
            self.enableEditorialFeaturesHelpTextLabel.text = "enableEditorialFeaturesHelpText".localized(contentfulService: self.services.contentful)

            
        }
    }

    func updateFormFieldsWithCurrentSession() {
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


    let toggleCellFactory = TableViewCellFactory<ToggleTableViewCell>()

    // Model.
    let locales: [ContentfulService.State.Locale] = [.americanEnglish, .german]
    let apis: [ContentfulService.State.API] = [.delivery, .preview]

    static let localesSectionIndex = 0
    static let apisSectionIndex = 1

    // MARK: UITableViewDelegate

    @IBOutlet weak var connectedSpaceCell: UITableViewCell!

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell === connectedSpaceCell {
            let connectedSpaceViewController = ConnectedSpaceViewController.new(services: services)
            navigationController?.pushViewController(connectedSpaceViewController, animated: true)
            return
        }
        guard (indexPath.section == SettingsViewController.localesSectionIndex ||
            indexPath.section == SettingsViewController.apisSectionIndex) &&
            indexPath.row != 0 else {
            return
        }

        let dataSourceIndex = indexPath.row - 1
        switch indexPath.section {
        case SettingsViewController.localesSectionIndex:
            services.contentful.stateMachine.state.locale = locales[dataSourceIndex]
            tableView.reloadData()
        case SettingsViewController.apisSectionIndex:
            services.contentful.stateMachine.state.api = apis[dataSourceIndex]
            tableView.reloadData()
        default: break
        }

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section != SettingsViewController.localesSectionIndex && indexPath.section != SettingsViewController.apisSectionIndex {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }

        if indexPath.row == 0 {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }

        let cell: UITableViewCell
        let dataSourceIndex = indexPath.row - 1
        switch indexPath.section {
        case SettingsViewController.localesSectionIndex:

            let isCurrentLocale = services.contentful.stateMachine.state.locale == locales[dataSourceIndex]
            let model = ToggleTableViewCell.Model(title: locales[dataSourceIndex].title(), isSelected: isCurrentLocale)
            cell = toggleCellFactory.cell(for: model, in: tableView, at: indexPath)
        case SettingsViewController.apisSectionIndex:
            let isCurrentAPI = services.contentful.stateMachine.state.api == apis[dataSourceIndex]
            let model = ToggleTableViewCell.Model(title: apis[dataSourceIndex].title(), isSelected: isCurrentAPI)
            cell = toggleCellFactory.cell(for: model, in: tableView, at: indexPath)
        default:
            fatalError()
        }
        return cell
    }

    // MARK: Interface Builder

    @IBOutlet weak var localeDescriptionLabel: UILabel!
    @IBOutlet weak var apiDescriptionLabel: UILabel!
    @IBOutlet weak var overrideConfigLabel: UILabel!
    @IBOutlet weak var connectedToSpaceLabel: UILabel!
    @IBOutlet weak var currentlyConnectedSpaceLabel: UILabel!

    @IBOutlet weak var spaceIdDescriptionLabel: UILabel!
    @IBOutlet weak var deliveryAccessTokenDescriptionLabel: UILabel!

    @IBOutlet weak var previewAccessTokenDescriptionLabel: UILabel!

    @IBOutlet weak var spaceIdTextField: CredentialTextField!
    @IBOutlet weak var deliveryAccessTokenTextField: CredentialTextField!
    @IBOutlet weak var previewAccessTokenTextField: CredentialTextField!
    @IBOutlet weak var credentialsHelpTextLabel: UILabel!

    @IBOutlet weak var editorialFeaturesSwitch: UISwitch!
    @IBAction func didToggleEditorialFeatures(_ sender: Any) {
        services.contentful.enableEditorialFeatures(editorialFeaturesSwitch.isOn)
    }

    @IBOutlet weak var enableEditorialFeaturesLabel: UILabel!
    @IBOutlet weak var enableEditorialFeaturesHelpTextLabel: UILabel!

    @objc func dismissKeyboard() {
        tableView.endEditing(true)
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == spaceIdTextField {
            spaceIdTextField.resignFirstResponder()
            deliveryAccessTokenTextField.becomeFirstResponder()
        } else if textField == deliveryAccessTokenTextField {
            deliveryAccessTokenTextField.resignFirstResponder()
            previewAccessTokenTextField.becomeFirstResponder()
        } else if textField == previewAccessTokenTextField {
            previewAccessTokenTextField.resignFirstResponder()

            // Attempt to save.
        }

        return true
    }

    weak var keyboardDoneButton: UIBarButtonItem?

    func textFieldDidBeginEditing(_ textField: UITextField) {


        let toolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: 50.0))

        toolbar.barStyle = UIBarStyle.default
        let keyboardDoneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(SettingsViewController.didTapSaveSettings(_:)))
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(SettingsViewController.dismissKeyboard)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            keyboardDoneButton
            ]
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar

        if textField == previewAccessTokenTextField {
            textField.returnKeyType = .done
        } else {
            textField.returnKeyType = .next
        }
        textField.becomeFirstResponder()
        self.keyboardDoneButton = keyboardDoneButton
        updateSubmitButtons()
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        textField.resignFirstResponder()
    }

    @objc func changeTextFieldText(_ sender: AnyObject) {
        updateSubmitButtons()
    }

    func updateSubmitButtons() {
        if spaceIdTextField.text?.isEmpty == false && deliveryAccessTokenTextField.text?.isEmpty == false && previewAccessTokenTextField.text?.isEmpty == false {
            navigationItem.rightBarButtonItem?.isEnabled = true
            keyboardDoneButton?.isEnabled = true
            previewAccessTokenTextField.enablesReturnKeyAutomatically = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            keyboardDoneButton?.isEnabled = false
            previewAccessTokenTextField.enablesReturnKeyAutomatically = true
        }
    }
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
