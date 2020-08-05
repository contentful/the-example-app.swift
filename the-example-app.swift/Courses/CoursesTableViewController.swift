        
import Foundation
import UIKit
import Contentful

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
    var coursesSectionModel: CoursesSectionModel = .loading {
        didSet {
            updateTableViewDelegate()
        }
    }

    enum CoursesSectionModel {
        case loaded([Course])
        case loading
        case errored(Error)
    }

    let coursesSectionIndex: Int = 1

    var categories: [Category]?

    var selectedCategory: Category?

    var onCategoryAppearance: (([Category]) -> Void)?

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
            // Filter courses by category.
            query.where(linksToEntryWithId: selectedCategory.id)
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
            DispatchQueue.main.async {
                self.title = "coursesLabel".localized(contentfulService: self.services.contentful)
                self.fetchCategoriesFromContentful()
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

    func fetchCategoriesFromContentful() {
        tableViewDataSource = LoadingTableViewDataSource()

        // Cancel the previous requests before making a new one.
        categoriesRequest?.cancel()
        coursesRequest?.cancel()

        categoriesRequest = services.contentful.client.fetchArray(of: Category.self, matching: categoriesQuery) { [unowned self] result in
            self.categoriesRequest = nil
            switch result {
            case .success(let arrayResponse):
                guard arrayResponse.items.count > 0 else {
                    self.setNoCategoriesErrorDataSource()
                    return
                }
                self.categories = arrayResponse.items

                // Call method for deep linking to a category.
                self.onCategoryAppearance?(arrayResponse.items)
                self.onCategoryAppearance = nil

                self.tableViewDataSource = self
                self.fetchCoursesFromContentful()

            case .failure(let error):
                let errorModel = ErrorTableViewCell.Model(error: error, services: self.services)
                self.tableViewDataSource = ErrorTableViewDataSource(model: errorModel)
            }
        }
    }

    func fetchCoursesFromContentful() {
        // Show loading state by settting the data source to nil.
        coursesSectionModel = .loading
        reloadCoursesSection()

        // Cancel the previous request before making a new one.
        coursesRequest?.cancel()
        coursesRequest = services.contentful.client.fetchArray(of: Course.self, matching: coursesQuery) { [unowned self] result in
            switch result {
            case .success(let arrayResponse):
                guard arrayResponse.items.count > 0 else {
                    self.setNoCoursesErrorDataSource()
                    return
                }
                self.coursesSectionModel = CoursesSectionModel.loaded(arrayResponse.items)

                if self.willResolveStatesOnCourses() == false {
                    self.reloadCoursesSection()
                }

            case .failure(let error):
                self.coursesSectionModel = CoursesSectionModel.errored(error)
                self.reloadCoursesSection()
            }
        }
    }

    func setNoCategoriesErrorDataSource() {
        let error = NoContentError.noCategories(contentfulService: services.contentful,
                                                route: Category.contentTypeId,
                                                fontSize: 14.0)
        let errorModel = ErrorTableViewCell.Model(error: error, services: services)
        tableViewDataSource = ErrorTableViewDataSource(model: errorModel)
    }

    func setNoCoursesErrorDataSource() {
        let error = NoContentError.noCourses(contentfulService: services.contentful,
                                             route: Course.contentTypeId,
                                             fontSize: 14.0)
        let errorModel = ErrorTableViewCell.Model(error: error, services: services)
        tableViewDataSource = ErrorTableViewDataSource(model: errorModel)
    }

    func willResolveStatesOnCourses() -> Bool {
        guard case .loaded(var courses) = coursesSectionModel else {
            return false
        }

        // Create a Dispatch Group to block until we've resolved the state(s) on all the courses.
        let dispatchGroup = DispatchGroup()

        let isResolvingState: Bool = courses.reduce(into: true) { (bool: inout Bool, course: Course) in
            dispatchGroup.enter()
            bool = bool && services.contentful.willResolveStateIfNecessary(for: course) { (result: Result<Course, Error>, _) in
                switch result {
                case .success(let statefulCourse):
                    if let index = courses.index(where: { $0.id == course.id }) {
                        courses[index] = statefulCourse

                        dispatchGroup.leave()
                    }

                case .failure:
                    break
                }
            }
        }
        // Callback after all courses have had their states resolved.
        dispatchGroup.notify(queue: DispatchQueue.main) { [unowned self] in
            self.coursesSectionModel = .loaded(courses)
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

            self.tableView.reloadSections(IndexSet(integer: self.coursesSectionIndex), with: UITableView.RowAnimation.automatic)
        }
    }

    func updateTableViewDelegate() {
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self, case .loaded = strongSelf.coursesSectionModel {
                strongSelf.tableView.delegate = strongSelf
            } else {
                self?.tableView.delegate = nil
            }
        }
    }

    // MARK: CategorySelectorDelegate

    public func select(category: Category?) {
        selectedCategory = category
        fetchCoursesFromContentful()

        if let selection = selectedCategory {
            Analytics.shared.logViewedRoute("/courses/\(selection.slug)", spaceId: services.contentful.credentials.spaceId)
        }
    }

    func didTapCategory(_ category: Category?) {
        guard selectedCategory != category else { return }

        select(category: category)
    }

    // MARK: UIViewController

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.accessibilityLabel = "Courses"

        tableView.registerNibFor(CategorySelectorTableViewCell.self)
        tableView.registerNibFor(CourseTableViewCell.self)
        tableView.registerNibFor(LoadingTableViewCell.self)
        tableView.registerNibFor(ErrorTableViewCell.self)

        // Enable table view cells to be sized dynamically based on inner content.
        tableView.rowHeight = UITableView.automaticDimension
        // Importantly, the estimated height is the height of the CategorySelectorTableViewCell.
        // This prevents a bug where the layout constraints break and print to the console.
        tableView.estimatedRowHeight = 60
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addStateObservations()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableViewDelegate()
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
        case 0:
            return 1

        // The section that displays courses has it's own loading state, so return 1 if there are no courses.
        case coursesSectionIndex:
            if case .loaded(let courses) = coursesSectionModel {
                return courses.count
            }
            return 1

        default:
            return 0
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
            cell = cellInCoursesSection(in: tableView, at: indexPath)

        default: fatalError()
        }
        return cell
    }

    func cellInCoursesSection(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch coursesSectionModel {
        case .loaded(let courses):
            let course = courses[indexPath.item]
            let model = CourseTableViewCell.Model(contentfulService: services.contentful,
                                                  course: course,
                                                  backgroundColor: color(for: indexPath.row)) { [unowned self] in
                                                    let courseViewController = CourseViewController(course: course, services: self.services)
                                                    self.navigationController?.pushViewController(courseViewController, animated: true)
            }
            cell = coursesCellFactory.cell(for: model, in: tableView, at: indexPath)
        case .loading:
            // Return a loading cell.
            cell = TableViewCellFactory<LoadingTableViewCell>().cell(for: nil, in: tableView, at: indexPath)
        case .errored(let error):
            let errorModel = ErrorTableViewCell.Model(error: error, services: services)
            cell = TableViewCellFactory<ErrorTableViewCell>().cell(for: errorModel, in: tableView, at: indexPath)
        }
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == coursesSectionIndex else { return }

        guard case .loaded(let courses) = coursesSectionModel else {
            fatalError()
        }
        let course = courses[indexPath.item]
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
