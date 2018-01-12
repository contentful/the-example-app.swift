
import Foundation
import UIKit

class TogglesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let services: Services

    init(services: Services) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
    }

    // Table view and cell rendering.
    var tableView: UITableView!
    let toggleCellFactory = TableViewCellFactory<ToggleTableViewCell>()

    // Model.
    let locales: [ContentfulService.Locale] = [.americanEnglish, .german]
    let apis: [ContentfulService.API] = [.delivery, .preview]

    static let sectionHeaderIdentifier = String(describing: TogglesHeaderView.self)

    static let localesSectionIndex = 0
    static let apisSectionIndex = 1

    override func loadView() {
        tableView = UITableView(frame: .zero)
        tableView.registerNibFor(ToggleTableViewCell.self)

        let sectionHeaderName = TogglesViewController.sectionHeaderIdentifier
        tableView.register(UINib(nibName: sectionHeaderName, bundle: nil), forHeaderFooterViewReuseIdentifier: sectionHeaderName)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.estimatedSectionHeaderHeight = 100
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(TogglesViewController.dismissModal))
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.dataSource = self
    }

    deinit {
        print("Deinit TogglesViewController")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc public func dismissModal() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: TogglesHeaderView?
        switch section {
        case TogglesViewController.localesSectionIndex:
            header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TogglesViewController.sectionHeaderIdentifier) as? TogglesHeaderView
            header?.label.text = "localeQuestion".localized()
        case TogglesViewController.apisSectionIndex:
            header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TogglesViewController.sectionHeaderIdentifier) as? TogglesHeaderView
            header?.label.text = "apiSwitcherHelp".localized()
        default:
            return nil
        }
        return header
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Two locales, and two apis.
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.section {
        case TogglesViewController.localesSectionIndex:
            let isCurrentLocale = services.contentful.localeStateMachine.state == locales[indexPath.row]
            let model = ToggleTableViewCell.Model(title: locales[indexPath.row].title(), isSelected: isCurrentLocale)
            cell = toggleCellFactory.cell(for: model, in: tableView, at: indexPath)
        case TogglesViewController.apisSectionIndex:
            let isCurrentAPI = services.contentful.apiStateMachine.state == apis[indexPath.row]
            let model = ToggleTableViewCell.Model(title: apis[indexPath.row].title(), isSelected: isCurrentAPI)
            cell = toggleCellFactory.cell(for: model, in: tableView, at: indexPath)
        default:
            fatalError()
        }
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case TogglesViewController.localesSectionIndex:
            services.contentful.localeStateMachine.state = locales[indexPath.row]
            tableView.reloadData()
        case TogglesViewController.apisSectionIndex:
            services.contentful.apiStateMachine.state = apis[indexPath.row]
            tableView.reloadData()
        default: break
        }
    }
}
