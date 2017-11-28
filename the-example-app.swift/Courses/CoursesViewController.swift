        
import Foundation
import UIKit
import Contentful

class CoursesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CategorySelectorDelegate {

    var courses: [Course]?

    var categories: [Category]?

    var selectedCategory: Category?

    let services: Services

    var tableView: UITableView!

    // We must retain the data source.
    var tableViewDataSource: UITableViewDataSource? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.dataSource = self!.tableViewDataSource
                self?.tableView.reloadData()
            }
        }
    }

    let coursesCellFactory = TableViewCellFactory<CourseTableViewCell>()
    let categorySelectorCellFactory = TableViewCellFactory<CategorySelectorTableViewCell>()

    var categoriesQuery: QueryOn<Category> {
        let localeCode = services.contentful.currentLocaleCode
        return QueryOn<Category>.localizeResults(withLocaleCode: localeCode)
    }

    var coursesQuery: QueryOn<Course> {
        let localeCode = services.contentful.currentLocaleCode
        let query = QueryOn<Course>.include(2).localizeResults(withLocaleCode: localeCode)
        if let selectedCategory = selectedCategory {
            // TODO: Add a method to the SDK for this.
            query.where(valueAtKeyPath: "fields.categories.sys.id", .equals(selectedCategory.id))
        }
        return query
    }

    init(services: Services) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateAPI(_ observation: StateMachine<Contentful.State>.Transition) {
        fetchCategoriesFromContentful()
    }

    func updateLocale(_ observation: StateMachine<Contentful.Locale>.Transition) {
        fetchCategoriesFromContentful()
    }

    func fetchCategoriesFromContentful() {
        services.contentful.client.fetchMappedEntries(matching: categoriesQuery) { [weak self] result in
            switch result {
            case .success(let arrayResponse):
                self?.categories = arrayResponse.items
                self?.fetchCoursesFromContentful()
                self?.tableViewDataSource = self

            case .error(let error):
                // TODO:
                print(error)
                self?.tableViewDataSource = ErrorTableViewDataSource(error: error)
            }
        }
    }

    func fetchCoursesFromContentful() {
        services.contentful.client.fetchMappedEntries(matching: coursesQuery) { [weak self] result in
            switch result {
            case .success(let arrayResponse):
                self?.courses = arrayResponse.items
                self?.tableViewDataSource = self

            case .error(let error):
                // TODO:
                print(error)
                self?.tableViewDataSource = ErrorTableViewDataSource(error: error)
            }
        }
    }

    // MARK: UIViewController

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.registerNibFor(CategorySelectorTableViewCell.self)
        tableView.registerNibFor(CourseTableViewCell.self)
        tableView.registerNibFor(LoadingTableViewCell.self)
        tableView.register(ErrorTableViewCell.self)

        // Enable table view cells to be sized dynamically based on inner content.
        tableView.rowHeight = UITableViewAutomaticDimension
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewDataSource = LoadingTableViewDataSource()
        tableView.delegate = self

        services.contentful.apiStateMachine.addTransitionObservation(updateAPI(_:))
        services.contentful.localeStateMachine.addTransitionObservation(updateLocale(_:))
    }

    // MARK: CategorySelectorDelegate

    func didSelectCategory(_ category: Category?) {
        selectedCategory = category
        fetchCoursesFromContentful()
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:     return 1
        // The section that displays courses has it's own loading state, so return 1 if there are no courses.
        case 1:     return courses?.count ?? 1
        default:    return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.section {
        case 0:
            let cellModel = CategorySelectorTableViewCell.Model(categories: categories, delegate: self, selectedCategory: selectedCategory)
            cell = categorySelectorCellFactory.cell(for: cellModel, in: tableView, at: indexPath)
        case 1:
            if let courses = courses {
                let course = courses[indexPath.item]
                cell = coursesCellFactory.cell(for: course, in: tableView, at: indexPath)
            } else {
                // Return a loading cell.
                cell = TableViewCellFactory<LoadingTableViewCell>().cell(for: nil, in: tableView, at: indexPath)
            }

        default: fatalError("TODO")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let course = courses?[indexPath.item] else {
            fatalError("TODO")
        }
        let courseViewController = CourseViewController(course: course, services: services)
        navigationController?.pushViewController(courseViewController, animated: true)
    }
}
