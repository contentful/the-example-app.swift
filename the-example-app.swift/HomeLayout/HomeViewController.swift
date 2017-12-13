
import Foundation
import UIKit
import Contentful
import Interstellar

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


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
    let layoutCopyCellFactory = TableViewCellFactory<LayoutCopyTableViewCell>()

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


    /**
     * The detail view controller for a course that is currenlty pushed onto the navigation stack.
     * This property is declared as weak so that when the navigaton controller pops the course view controller
     * it will not be retained here.
     */
    weak var courseViewController: CourseViewController?

    init(services: Services) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
        self.tabBarItem = UITabBarItem(title: "Home", image: nil, selectedImage: nil)

        self.title = "The iOS example app"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateAPI(_ observation: StateMachine<Contentful.State>.Transition) {
        fetchLayoutFromContenful()
    }

    func updateLocale(_ observation: StateMachine<Contentful.Locale>.Transition) {
        fetchLayoutFromContenful()
    }

    func fetchLayoutFromContenful() {
        // Nullify homeLayout property so that the loading cell will show up.
        homeLayout = nil

        tableViewDataSource = LoadingTableViewDataSource()

        // Cancel the previous request before making a new one.
        layoutRequest?.cancel()
        layoutRequest = services.contentful.client.fetchMappedEntries(matching: query) { [unowned self] result in
            switch result {
            case .success(let arrayResponse):
                self.homeLayout = arrayResponse.items.first!
                self.tableViewDataSource = self
                self.updatePushedCourseViewController()
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
            guard var statefulPreviewHomeLayout = result.value, let statefulHomeModules = statefulPreviewHomeLayout.modules else { return }
            guard let deliveryModules = deliveryHomeLayout?.modules else { return }

            statefulPreviewHomeLayout = self.services.contentful.inferStateFromLinkedModuleDiffs(statefulRootAndModules: (statefulPreviewHomeLayout, statefulHomeModules), deliveryModules: deliveryModules)
            // TODO: Update pills layout
        }
    }

    func updatePushedCourseViewController() {
        guard let currentCourse = courseViewController?.course else { return }

        if let highlightedCourseModules = homeLayout?.modules?.filter({ $0 is HighlightedCourse }) as? [HighlightedCourse] {
            let highlightedCourses = highlightedCourseModules.flatMap({ $0.course })
            if let course = highlightedCourses.filter({ $0.id == currentCourse.id }).first {
                courseViewController?.course = course
            }
        }
    }

    // MARK: UIViewController

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.registerNibFor(HighlightedCourseTableViewCell.self)
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
        services.contentful.localeStateMachine.addTransitionObservationAndObserveInitialState(updateLocale(_:))
    }


    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeLayout?.modules?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if let highlightedCourse = homeLayout?.modules?[indexPath.row] as? HighlightedCourse {

            let model = HighlightedCourseTableViewCell.Model(highlightedCourse: highlightedCourse) { [unowned self] in
                let courseViewController = CourseViewController(course: highlightedCourse.course, services: self.services)
                self.navigationController?.pushViewController(courseViewController, animated: true)
                self.courseViewController = courseViewController
            }
            cell = highlighteCourseCellFactory.cell(for: model, in: tableView, at: indexPath)

        } else if let layoutCopy = homeLayout?.modules?[indexPath.row] as? LayoutCopy {
            cell = layoutCopyCellFactory.cell(for: layoutCopy, in: tableView, at: indexPath)

        } else if let layoutHeroImage = homeLayout?.modules?[indexPath.row] as? LayoutHeroImage {
            cell = heroImageCellFactory.cell(for: layoutHeroImage, in: tableView, at: indexPath)

        } else {
            fatalError("TODO")
        }
        return cell
    }
}
