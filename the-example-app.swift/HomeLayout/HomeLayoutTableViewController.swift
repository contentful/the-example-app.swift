
import Foundation
import UIKit
import Contentful
import Interstellar

class HomeLayoutTableViewController: UIViewController, TabBarTabViewController, UITableViewDelegate, UITableViewDataSource, CustomNavigable {

    var tabItem: UITabBarItem {
        return UITabBarItem(title: "homeLabel".localized(contentfulService: services.contentful),
                            image: UIImage(named: "tabbar-icon-home"),
                            selectedImage: nil)
    }

    let services: Services

    // Data model for this view controller.
    var homeLayout: HomeLayout?

    var tableViewDataSource: UITableViewDataSource? {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.tableView.dataSource = self.tableViewDataSource
                self.tableView.reloadData()
            }
        }
    }

    // Table view and cell rendering.
    var tableView: UITableView!
    let highlighteCourseCellFactory = TableViewCellFactory<LayoutHighlightedCourseTableViewCell>()
    let heroImageCellFactory = TableViewCellFactory<LayoutHeroImageTableViewCell>()
    let layoutCopyDefaultCellFactory = TableViewCellFactory<LayoutCopyDefaultTableViewCell>()
    let layoutCopyEmphasizedCellFactory = TableViewCellFactory<LayoutCopyEmphasizedTableViewCell>()
    let stateCellFactory = TableViewCellFactory<ResourceStatesTableViewCell>()

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

    deinit {
        print("Deallocaed HomeViewController")
    }

    // State change reactions.
    var stateObservationToken: String?

    var contentfulServiceStateObservatinToken: String?

    func addStateObservations() {
        stateObservationToken = services.contentful.stateMachine.addTransitionObservationAndObserveInitialState { [unowned self] _ in
            DispatchQueue.main.async {
                self.fetchLayoutFromContenful()
            }
        }

        // Observation for when we change spaces.
        contentfulServiceStateObservatinToken = services.contentfulStateMachine.addTransitionObservation { [unowned self] _ in
            DispatchQueue.main.async {
                self.removeStateObservations()
                self.addStateObservations()
            }
        }
    }

    func removeStateObservations() {
        if let token = stateObservationToken {
            services.contentful.stateMachine.stopObserving(token: token)
            stateObservationToken = nil
        }

        if let token = contentfulServiceStateObservatinToken {
            services.contentfulStateMachine.stopObserving(token: token)
            contentfulServiceStateObservatinToken = nil
        }
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
                let errorModel = ErrorTableViewCell.Model(error: error,
                                                          contentfulService: self.services.contentful)
                self.tableViewDataSource = ErrorTableViewDataSource(model: errorModel)
            }
        }
    }

    func resolveStatesOnLayoutModules() {
        guard let homeLayout = self.homeLayout else { return }

        services.contentful.willResolveStateIfNecessary(for: homeLayout) { [unowned self] (result: Result<HomeLayout>, deliveryHomeLayout: HomeLayout?) in
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

        tableView.registerNibFor(LayoutHighlightedCourseTableViewCell.self)
        tableView.registerNibFor(LayoutCopyDefaultTableViewCell.self)
        tableView.registerNibFor(LayoutCopyEmphasizedTableViewCell.self)
        tableView.registerNibFor(LayoutHeroImageTableViewCell.self)
        tableView.registerNibFor(ResourceStatesTableViewCell.self)

        tableView.registerNibFor(LoadingTableViewCell.self)
        tableView.registerNibFor(ErrorTableViewCell.self)
        
        // Enable table view cells to be sized dynamically based on inner content.
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.accessibilityLabel = "Home"
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addStateObservations()
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.logViewedRoute("/", spaceId: services.contentful.spaceId)
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

        if let highlightedCourse = homeLayout?.modules?[indexPath.row] as? LayoutHighlightedCourse {

            let model = LayoutHighlightedCourseTableViewCell.Model(highlightedCourse: highlightedCourse) { [unowned self] in
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

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if let homeLayout = homeLayout, homeLayout.state == .upToDate {
                return 0.0
            }
            return UITableViewAutomaticDimension
        case 1:
            return UITableViewAutomaticDimension
        default:
            fatalError()
        }
    }
}
