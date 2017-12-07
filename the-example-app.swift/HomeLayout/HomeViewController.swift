
import Foundation
import UIKit
import Contentful


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var homeLayout: HomeLayout?
    
    let services: Services

    var tableView: UITableView!

    var tableViewDataSource: UITableViewDataSource? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.dataSource = self!.tableViewDataSource
                self?.tableView.reloadData()
            }
        }
    }

    let highlighteCourseCellFactory = TableViewCellFactory<HighlightedCourseTableViewCell>()
    let heroImageCellFactory = TableViewCellFactory<LayoutHeroImageTableViewCell>()
    let layoutCopyCellFactory = TableViewCellFactory<LayoutCopyTableViewCell>()


    var query: QueryOn<HomeLayout> {
        // Search for the entry for the 'home screen' by its slug.
        let query = QueryOn<HomeLayout>.where(field: .slug, .equals("home"))

        // Include links that are two levels deep in the API response. In this case, specifying
        // 4 levels deep will give us the home layout > it's modules > the course for a highlighted course module
        // it's lessons and their lesson modules
        query.include(4)
        return query
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

    func updateAPI(_ observation: StateMachine<Contentful.State>.Transition) {
        fetchLayoutFromContenful()
    }

    func updateLocale(_ observation: StateMachine<Contentful.Locale>.Transition) {
        fetchLayoutFromContenful()
    }

    func fetchLayoutFromContenful() {
        services.contentful.client.fetchMappedEntries(matching: query) { [weak self] result in
            switch result {
            case .success(let arrayResponse):
                self?.homeLayout = arrayResponse.items.first!
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

        tableView.registerNibFor(HighlightedCourseTableViewCell.self)
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

        fetchLayoutFromContenful()

        services.contentful.apiStateMachine.addTransitionObservation(updateAPI(_:))
        services.contentful.localeStateMachine.addTransitionObservation(updateLocale(_:))
    }


    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeLayout?.modules?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if let highlightedCourse = homeLayout?.modules?[indexPath.row] as? HighlightedCourse {
            cell = highlighteCourseCellFactory.cell(for: highlightedCourse, in: tableView, at: indexPath)

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
