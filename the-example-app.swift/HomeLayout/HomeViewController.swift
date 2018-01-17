
import Foundation
import UIKit
import Contentful
import Interstellar

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomNavigable {

    let services: Services

    // Data model for this view controller.
    var homeLayout: HomeLayout?

    var tableViewDataSource: UITableViewDataSource? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.dataSource = self!.tableViewDataSource
                self?.tableView.reloadData()
            }
        }
    }

    // Table view and cell rendering.
    var tableView: UITableView!
    let highlighteCourseCellFactory = TableViewCellFactory<HighlightedCourseTableViewCell>()
    let heroImageCellFactory = TableViewCellFactory<LayoutHeroImageTableViewCell>()
    let layoutCopyDefaultCellFactory = TableViewCellFactory<LayoutCopyDefaultTableViewCell>()
    let layoutCopyEmphasizedCellFactory = TableViewCellFactory<LayoutCopyEmphasizedTableViewCell>()
    let stateCellFactory = TableViewCellFactory<ModuleOwnerStateTableViewCell>()

    var query: QueryOn<HomeLayout> {
        let localeCode = services.contentful.currentLocaleCode
        // Search for the entry for the 'home screen' by its slug.
        let query = QueryOn<HomeLayout>.where(field: .slug, .equals("home")).localizeResults(withLocaleCode: localeCode)

        // Include links that are two levels deep in the API response. In this case, specifying
        // 4 levels deep will give us the home layout > it's modules > the course for a highlighted course module
        // it's lessons and their lesson modules and linked assets
        query.include(4)
        return query
    }

    // Requests.
    var layoutRequest: URLSessionTask?

    // MARK: CustomNavigable

    var hasCustomToolbar: Bool {
        return false
    }

    var prefersLargeTitles: Bool {
        return true
    }

    init(services: Services) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Home", image: nil, selectedImage: nil)

        self.title = "The iOS example app"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // State change reactions.
    var apiStateObservationToken: String?
    var localeStateObservationToken: String?
    var editorialFeaturesStateObservationToken: String?

    func addStateObservations() {
        apiStateObservationToken = services.contentful.apiStateMachine.addTransitionObservation(updateAPI(_:))
        editorialFeaturesStateObservationToken = services.contentful.editorialFeaturesStateMachine.addTransitionObservation(updateEditorialFeatures(_:))
        localeStateObservationToken = services.contentful.localeStateMachine.addTransitionObservationAndObserveInitialState(updateLocale(_:))
    }

    func removeStateObservations() {
        if let token = apiStateObservationToken {
            services.contentful.apiStateMachine.stopObserving(token: token)
        }
        if let token = localeStateObservationToken {
            services.contentful.localeStateMachine.stopObserving(token: token)
        }
        if let token = editorialFeaturesStateObservationToken {
            services.contentful.editorialFeaturesStateMachine.stopObserving(token: token)
        }
    }

    func updateAPI(_ observation: StateMachine<ContentfulService.API>.Transition) {
        fetchLayoutFromContenful()
    }

    func updateEditorialFeatures(_ observation: StateMachine<Bool>.Transition) {
        fetchLayoutFromContenful()
    }

    func updateLocale(_ observation: StateMachine<ContentfulService.Locale>.Transition) {
        fetchLayoutFromContenful()
    }

    func fetchLayoutFromContenful() {
        tableViewDataSource = LoadingTableViewDataSource()

        // Cancel the previous request before making a new one.
        layoutRequest?.cancel()
        layoutRequest = services.contentful.client.fetchMappedEntries(matching: query) { [unowned self] result in
            switch result {
            case .success(let arrayResponse):
                self.homeLayout = arrayResponse.items.first!
                self.tableViewDataSource = self
                self.resolveStatesOnLayoutModules()

            case .error(let error):
                // TODO:
                print(error)
                self.tableViewDataSource = ErrorTableViewDataSource(error: error)
            }
        }
    }

    func resolveStatesOnLayoutModules() {
        guard let homeLayout = self.homeLayout else { return }

        services.contentful.resolveStateIfNecessary(for: homeLayout) { [unowned self] (result: Result<HomeLayout>, deliveryHomeLayout: HomeLayout?) in
            guard var statefulPreviewHomeLayout = result.value, let statefulPreviewHomeModules = statefulPreviewHomeLayout.modules else { return }
            guard let deliveryModules = deliveryHomeLayout?.modules else { return }

            statefulPreviewHomeLayout = self.services.contentful.inferStateFromLinkedModuleDiffs(statefulRootAndModules: (statefulPreviewHomeLayout, statefulPreviewHomeModules), deliveryModules: deliveryModules)
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
    }

    // MARK: UIViewController

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.registerNibFor(HighlightedCourseTableViewCell.self)
        tableView.registerNibFor(LayoutCopyDefaultTableViewCell.self)
        tableView.registerNibFor(LayoutCopyEmphasizedTableViewCell.self)
        tableView.registerNibFor(LayoutHeroImageTableViewCell.self)
        tableView.registerNibFor(ModuleOwnerStateTableViewCell.self)

        tableView.registerNibFor(LoadingTableViewCell.self)

        tableView.register(ErrorTableViewCell.self)
        
        // Enable table view cells to be sized dynamically based on inner content.
        tableView.rowHeight = UITableViewAutomaticDimension
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self

        services.contentful.apiStateMachine.addTransitionObservation(updateAPI(_:))
        services.contentful.editorialFeaturesStateMachine.addTransitionObservation(updateEditorialFeatures(_:))
        services.contentful.localeStateMachine.addTransitionObservationAndObserveInitialState(updateLocale(_:))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addStateObservations()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeStateObservations()
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if services.contentful.shouldShowResourceStateLabels {
                return 1
            }
            return 0
        case 1:
            return homeLayout?.modules?.count ?? 0
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return stateCellFactory.cell(for: homeLayout!.state, in: tableView, at: indexPath)
        case 1:
            return cellInModulesSection(tableView: tableView, indexPath: indexPath)
        default:
            fatalError()
        }
    }

    func cellInModulesSection(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell

        if let highlightedCourse = homeLayout?.modules?[indexPath.row] as? HighlightedCourse {

            let model = HighlightedCourseTableViewCell.Model(highlightedCourse: highlightedCourse) { [unowned self] in
                let courseViewController = CourseViewController(course: highlightedCourse.course, services: self.services)
                self.navigationController?.pushViewController(courseViewController, animated: true)
            }
            cell = highlighteCourseCellFactory.cell(for: model, in: tableView, at: indexPath)

        } else if let layoutCopy = homeLayout?.modules?[indexPath.row] as? LayoutCopy {
            cell = layoutCopy.visualStyle == .emphasized ? layoutCopyEmphasizedCellFactory.cell(for: layoutCopy, in: tableView, at: indexPath) : layoutCopyDefaultCellFactory.cell(for: layoutCopy, in: tableView, at: indexPath)

        } else if let layoutHeroImage = homeLayout?.modules?[indexPath.row] as? LayoutHeroImage {
            cell = heroImageCellFactory.cell(for: layoutHeroImage, in: tableView, at: indexPath)

        } else {
            fatalError()
        }
        return cell
    }
}
