

import Foundation
import UIKit
import Contentful
import Interstellar

class SettingsViewController: UITableViewController, TabBarTabViewController, CustomNavigable, QRScannerDelegate {

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

    var onAppear: (() -> Void)?

    // MARK: QRScannerDelegate

    func shouldOpenScannedURL(_ url: URL) -> Bool {
        return url.absoluteString.hasPrefix("the-example-app.swift")
    }

    // MARK: UIViewController

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

        view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha:1.0)

        addObservations()

        services.contentfulStateMachine.addTransitionObservation { [unowned self] _ in
            DispatchQueue.main.async {
                self.resetErrors()
            }
        }
        services.contentfulStateMachine.addTransitionObservationAndObserveInitialState { [unowned self] _ in
            DispatchQueue.main.async {
                self.updateOtherViewsCurrentSessionInfo()
                self.removeObservations()
                self.addObservations()
            }
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        onAppear?()
        onAppear = nil

        Analytics.shared.logViewedRoute("/settings", spaceId: services.contentful.spaceId)
    }

    // State change reactions.
    var stateObservationToken: String?

    func removeObservations() {
        if let token = stateObservationToken {
            services.contentful.stateMachine.stopObserving(token: token)
            stateObservationToken = nil
        }
    }

    func addObservations() {
        // Update all text labels.
        stateObservationToken = services.contentful.stateMachine.addTransitionObservationAndObserveInitialState { [unowned self] _ in
            DispatchQueue.main.async {
                self.title = "settingsLabel".localized(contentfulService: self.services.contentful)

                self.localeDescriptionLabel.text = "localeQuestion".localized(contentfulService: self.services.contentful)
                self.apiDescriptionLabel.text = "apiSwitcherHelp".localized(contentfulService: self.services.contentful)

                self.connectedToSpaceLabel.text = "connectedToSpaceLabel".localized(contentfulService: self.services.contentful)

                self.enableEditorialFeaturesLabel.text = "enableEditorialFeaturesLabel".localized(contentfulService: self.services.contentful)
                self.enableEditorialFeaturesHelpTextLabel.text = "enableEditorialFeaturesHelpText".localized(contentfulService: self.services.contentful)
                self.tableView.reloadData()
            }
        }
    }

    func updateOtherViewsCurrentSessionInfo() {
        editorialFeaturesSwitch.isOn = services.contentful.editorialFeaturesAreEnabled

        let _ = services.contentful.client.fetchSpace().then { [unowned self] space in
            DispatchQueue.main.async {
                self.currentlyConnectedSpaceLabel.text = space.name + " (" + space.id + ")"
            }
        }
    }

    public var isShowingError: Bool = false

    func validationErrorMessageFor(textField: UITextField) -> String? {
        if textField.text == nil || textField.text!.isEmpty {
            return "fieldIsRequiredLabel".localized(contentfulService: services.contentful)
        }
        return nil
    }

    func resetErrors() {
        DispatchQueue.main.async { [unowned self] in
            self.isShowingError = false
            self.tableView.beginUpdates()
            self.tableView.tableHeaderView = nil
            self.tableView.endUpdates()
        }
    }

    public func showErrorHeader(credentialsError: CredentialsTester.Error) {
        DispatchQueue.main.async {

            var errorMessages = [String]()
            for (_, errorMessage) in credentialsError.errorMessages {
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
    let apis: [ContentfulService.State.API] = [.delivery, .preview]

    static let localesSectionIndex = 0
    static let apisSectionIndex = 1

    // MARK: UITableViewDelegate

    @IBOutlet weak var connectedSpaceCell: UITableViewCell!
    @IBOutlet weak var qrScannerCell: UITableViewCell!

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell === connectedSpaceCell {
            let connectedSpaceViewController = ConnectedSpaceViewController.new(services: services)
            navigationController?.pushViewController(connectedSpaceViewController, animated: true)
            return
        }
        if cell === qrScannerCell {
            let qrScannerViewController = QRScannerViewController(delegate: self)
            navigationController?.pushViewController(qrScannerViewController, animated: true)
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
            services.contentful.stateMachine.state.locale = services.contentful.locales[dataSourceIndex]
            tableView.reloadData()
        case SettingsViewController.apisSectionIndex:
            services.contentful.stateMachine.state.api = apis[dataSourceIndex]
            tableView.reloadData()
        default: break
        }
    }

    // The following 3 datasource method overrides are to enable proper handling of dynamically inserting
    // extra locale cells into what is otherwise a static table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SettingsViewController.localesSectionIndex {
            return services.contentful.locales.count + 1
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section != SettingsViewController.localesSectionIndex {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        if indexPath.row == 0 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        return 44
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section != SettingsViewController.localesSectionIndex {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
        if indexPath.row == 0 {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
        return 0
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

            let isCurrentLocale = services.contentful.stateMachine.state.locale == services.contentful.locales[dataSourceIndex]
            let model = ToggleTableViewCell.Model(title: services.contentful.locales[dataSourceIndex].name, isSelected: isCurrentLocale)
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
    @IBOutlet weak var connectedToSpaceLabel: UILabel!
    @IBOutlet weak var currentlyConnectedSpaceLabel: UILabel!

    @IBOutlet weak var editorialFeaturesSwitch: UISwitch!
    @IBAction func didToggleEditorialFeatures(_ sender: Any) {
        services.contentful.enableEditorialFeatures(editorialFeaturesSwitch.isOn)
    }

    @IBOutlet weak var enableEditorialFeaturesLabel: UILabel!
    @IBOutlet weak var enableEditorialFeaturesHelpTextLabel: UILabel!
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
