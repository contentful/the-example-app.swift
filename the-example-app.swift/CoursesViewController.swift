        
import Foundation
import UIKit
import Contentful

class CoursesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var courses: [Course]?

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

    let tableViewCellFactory = TableViewCellFactory<CourseTableViewCell>()

    var query: QueryOn<Course> {
        let localeCode = services.contentful.currentLocaleCode
        return QueryOn<Course>.include(2).localizeResults(withLocaleCode: localeCode)
    }

    init(services: Services) {
        self.services = services
        super.init(nibName: nil, bundle: nil)

        self.title = NSLocalizedString("Courses", comment: "")
//        self.tabBarItem = UITabBarItem(title: "Courses", image: nil, selectedImage: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateAPI(_ observation: StateMachine<Contentful.State>.Transition) {
        fetchCoursesFromContentful()
    }

    func updateLocale(_ observation: StateMachine<Contentful.Locale>.Transition) {
        fetchCoursesFromContentful()
    }

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.registerNibFor(CourseTableViewCell.self)
        tableView.registerNibFor(LoadingTableViewCell.self)
        tableView.register(ErrorTableViewCell.self)

        // Enable table view cells to be sized dynamically based on inner content.
        tableView.rowHeight = UITableViewAutomaticDimension
        view = tableView
    }

    func fetchCoursesFromContentful() {
        let query = self.query
        services.contentful.client.fetchMappedEntries(matching: query) { [weak self] result in
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

    override func viewDidLoad() {
        super.viewDidLoad()

        tableViewDataSource = LoadingTableViewDataSource()
        tableView.delegate = self

        services.contentful.apiStateMachine.addTransitionObservation(updateAPI(_:))
        services.contentful.localeStateMachine.addTransitionObservation(updateLocale(_:))
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let course = courses?[indexPath.item] else {
            fatalError("TODO")
        }
        let cell = tableViewCellFactory.cell(for: course, in: tableView, at: indexPath)
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
