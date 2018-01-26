        
import Foundation
import UIKit
import Contentful
import Interstellar

class CoursesTableViewController: UIViewController, TabBarTabViewController, UITableViewDataSource, UITableViewDelegate, CategorySelectorDelegate {

    var tabItem: UITabBarItem {
        return UITabBarItem(title: "coursesLabel".localized(contentfulService: services.contentful),
                            image: UIImage(named: "tabbar-icon-courses"),
                            selectedImage: nil)
    }

    init(services: Services) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let services: Services

    // Data model for this view controller.
    var courses: [Course]?

    let coursesSectionIndex: Int = 1

    var categories: [Category]?

    var selectedCategory: Category?

    // We must retain the data source.
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
    let coursesCellFactory = TableViewCellFactory<CourseTableViewCell>()
    let categorySelectorCellFactory = TableViewCellFactory<CategorySelectorTableViewCell>()

    // Contentful queries.
    var categoriesQuery: QueryOn<Category> {
        let localeCode = services.contentful.currentLocaleCode
        return QueryOn<Category>.localizeResults(withLocaleCode: localeCode)
    }

    var coursesQuery: QueryOn<Course> {
        let localeCode = services.contentful.currentLocaleCode
        let query = QueryOn<Course>.include(2).localizeResults(withLocaleCode: localeCode)
        try! query.order(by: Ordering(sys: .createdAt, inReverse: true))
        if let selectedCategory = selectedCategory {
            query.where(valueAtKeyPath: "fields.categories.sys.id", .equals(selectedCategory.id))
        }
        return query
    }

    // Requests.
    var coursesRequest: URLSessionTask?
    var categoriesRequest: URLSessionTask?

    // State change reactions.
    var stateObservationToken: String?
    var contentfulServiceStateObservatinToken: String?

    func addStateObservations() {
        stateObservationToken = services.contentful.stateMachine.addTransitionObservationAndObserveInitialState { [unowned self] _ in
            self.title = "coursesLabel".localized(contentfulService: self.services.contentful)
            self.fetchCategoriesFromContentful()
        }

        // Observation for when we change spaces.
        contentfulServiceStateObservatinToken = services.contentfulStateMachine.addTransitionObservation { [unowned self] (_) in
            self.removeStateObservations()
            self.addStateObservations()
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

    func fetchCategoriesFromContentful() {
        tableViewDataSource = LoadingTableViewDataSource()

        // Cancel the previous requests before making a new one.
        categoriesRequest?.cancel()
        coursesRequest?.cancel()

        categoriesRequest = services.contentful.client.fetchMappedEntries(matching: categoriesQuery) { [unowned self] result in
            self.categoriesRequest = nil
            switch result {
            case .success(let arrayResponse):
                self.categories = arrayResponse.items
                self.tableViewDataSource = self
                self.fetchCoursesFromContentful()

            case .error(let error):
                let errorModel = ErrorTableViewDataSource.Model(error: error,
                                                                contentfulService: self.services.contentful)
                self.tableViewDataSource = ErrorTableViewDataSource(model: errorModel)
            }
        }
    }

    func fetchCoursesFromContentful() {
        // Show loading state by settting the data source to nil.
        courses = nil
        reloadCoursesSection()

        // Cancel the previous request before making a new one.
        coursesRequest?.cancel()
        coursesRequest = services.contentful.client.fetchMappedEntries(matching: coursesQuery) { [unowned self] result in
            switch result {
            case .success(let arrayResponse):
                self.courses = arrayResponse.items
                if self.willResolveStatesOnCourses() == false {
                    self.reloadCoursesSection()
                }

            case .error(let error):
                let errorModel = ErrorTableViewDataSource.Model(error: error,
                                                                contentfulService: self.services.contentful)
                self.tableViewDataSource = ErrorTableViewDataSource(model: errorModel)
            }
        }
    }

    func willResolveStatesOnCourses() -> Bool {
        guard let courses = self.courses else {
            return false
        }

        // Create a Dispatch Group to block until we've resolved the state(s) on all the courses.
        let dispatchGroup = DispatchGroup()

        let isResolvingState: Bool = courses.reduce(into: true) { (bool: inout Bool, course: Course) in
            dispatchGroup.enter()
            bool = bool && services.contentful.willResolveStateIfNecessary(for: course) { [unowned self] (result: Result<Course>, _) in
                guard let statefulCourse = result.value else { return }

                if let index = courses.index(where: { $0.id == course.id }) {
                    self.courses?[index] = statefulCourse

                    dispatchGroup.leave()
                }
            }
        }
        // Callback after all courses have had their states resolved.
        dispatchGroup.notify(queue: DispatchQueue.main) { [unowned self] in
            self.reloadCoursesSection()
        }
        return isResolvingState
    }

    func reloadCoursesSection() {
        // Guard against crash for updating a table view section that is not currently being rendered.
        guard categoriesRequest == nil else { return }

        DispatchQueue.main.async { [unowned self] in
            guard self === self.tableView.dataSource else { return }
            guard self.tableView.numberOfSections > self.coursesSectionIndex else { return }

            self.tableView.beginUpdates()
            self.tableView.reloadSections(IndexSet(integer: self.coursesSectionIndex), with: .none)
            self.tableView.endUpdates()
        }
    }

    // MARK: CategorySelectorDelegate

    func didSelectCategory(_ category: Category?) {
        guard selectedCategory != category else { return }

        selectedCategory = category
        fetchCoursesFromContentful()
    }

    // MARK: UIViewController

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.registerNibFor(CategorySelectorTableViewCell.self)
        tableView.registerNibFor(CourseTableViewCell.self)
        tableView.registerNibFor(LoadingTableViewCell.self)
        tableView.registerNibFor(ErrorTableViewCell.self)

        // Enable table view cells to be sized dynamically based on inner content.
        tableView.rowHeight = UITableViewAutomaticDimension
        // Importantly, the estimated height is the height of the CategorySelectorTableViewCell.
        // This prevents a bug where the layout constraints break and print to the console.
        tableView.estimatedRowHeight = 60
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        addStateObservations()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if courses != nil {
            tableView.delegate = self
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.delegate = nil
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:                     return 1
        // The section that displays courses has it's own loading state, so return 1 if there are no courses.
        case coursesSectionIndex:   return courses?.count ?? 1
        default:                    return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.section {
        case 0:
            let cellModel = CategorySelectorTableViewCell.Model(contentfulService: services.contentful,
                                                                categories: categories,
                                                                delegate: self,
                                                                selectedCategory: selectedCategory)
            cell = categorySelectorCellFactory.cell(for: cellModel, in: tableView, at: indexPath)
        case coursesSectionIndex:
            if let courses = courses {
                let course = courses[indexPath.item]
                let model = CourseTableViewCell.Model(contentfulService: services.contentful,
                                                      course: course,
                                                      backgroundColor: color(for: indexPath.row)) { [unowned self] in
                    let courseViewController = CourseViewController(course: course, services: self.services)
                    self.navigationController?.pushViewController(courseViewController, animated: true)
                }
                cell = coursesCellFactory.cell(for: model, in: tableView, at: indexPath)
            } else {
                // Return a loading cell.
                cell = TableViewCellFactory<LoadingTableViewCell>().cell(for: nil, in: tableView, at: indexPath)
            }

        default: fatalError()
        }
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == coursesSectionIndex else { return }
        
        guard let course = courses?[indexPath.item] else {
            fatalError()
        }
        let courseViewController = CourseViewController(course: course, services: services)
        navigationController?.pushViewController(courseViewController, animated: true)
    }

    func color(for index: Int) -> UIColor {
        switch index % 2 {
        case 0:
            return UIColor(red: 0.33, green: 0.38, blue: 0.44, alpha: 1.0)
        case 1:
            return UIColor(red: 0.04, green: 0.67, blue: 0.46, alpha: 1.0)
        default:
            return UIColor(red: 0.33, green: 0.38, blue: 0.44, alpha: 1.0)
        }
    }
}
