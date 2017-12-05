
import Foundation
import UIKit
import Contentful
import Interstellar

class CourseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var course: Course? {
        didSet {
            if course != nil {
                DispatchQueue.main.async { [weak self] in
                    self?.tableViewDataSource = self
                    self?.tableView?.delegate = self
                }
            }
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }

    var services: Services

    var tableView: UITableView! 

    /**
     * The lessons collection view controller for a course that is currenlty pushed onto the navigation stack.
     * This property is declared as weak so that when the navigaton controller pops the course view controller
     * it will not be retained here.
     */
    weak var lessonsViewController: LessonsCollectionViewController?

    // We must retain the data source.
    var tableViewDataSource: UITableViewDataSource? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.dataSource = self!.tableViewDataSource
                self?.tableView?.reloadData()
            }
        }
    }

    let courseOverviewCellFactory = TableViewCellFactory<CourseOverviewTableViewCell>()
    let lessonCellFactory = TableViewCellFactory<LessonTableViewCell>()

    init(course: Course?, services: Services) {
        self.course = course
        self.services = services
        super.init(nibName: nil, bundle: nil)

        self.hidesBottomBarWhenPushed = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func pushLessonsCollectionViewAndShowLesson(at index: Int) {
        let lessonsViewController = LessonsCollectionViewController(course: course, services: services)

        lessonsViewController.onLoad = {
            // TODO: Better API.
            lessonsViewController.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
        navigationController?.pushViewController(lessonsViewController, animated: true)
        self.lessonsViewController = lessonsViewController
    }



    // MARK: UIViewController

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.registerNibFor(CourseOverviewTableViewCell.self)
        tableView.registerNibFor(LessonTableViewCell.self)
        tableView.registerNibFor(LoadingTableViewCell.self)

        // Enable table view cells to be sized dynamically based on inner content.
        tableView.rowHeight = UITableViewAutomaticDimension
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if course != nil {
            tableViewDataSource = self
            tableView.delegate = self
        } else {
            tableViewDataSource = LoadingTableViewDataSource()
            // TODO: reload course...
        }

    }

    func showLessonWithSlug(_ slug: String?) {
        lessonsViewController?.course = course
        if let slug = slug, let lessonsViewController = lessonsViewController {
            lessonsViewController.showLessonWithSlug(slug)
        }
    }

    public func fetchCourseWithSlug(_ slug: String, showLessonWithSlug lessonSlug: String? = nil) {
        let query = QueryOn<Course>.where(field: .slug, .equals(slug)).include(3)
        services.contentful.client.fetchMappedEntries(matching: query) { [weak self] result in
            switch result {
            case .success(let arrayResponse):
                if arrayResponse.items.count == 0 {

                    // TODO: Show error.
                    // TODO: Pop in the case that we have come from a deep link.
                    return
                }
                self?.course = arrayResponse.items.first
                self?.showLessonWithSlug(lessonSlug)
            case .error:
                // TODO:
                break
            }
        }
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        pushLessonsCollectionViewAndShowLesson(at: indexPath.row)
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:     return 1
        case 1:     return course?.lessons?.count ?? 0
        default:    return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.section {
        case 0:
            assert(indexPath.row == 0)
            guard let course = course else {
                fatalError()
            }
            cell = courseOverviewCellFactory.cell(for: course, in: tableView, at: indexPath)
        case 1:
            guard let lesson = course?.lessons?[indexPath.item] else {
                fatalError()
            }
            cell = lessonCellFactory.cell(for: lesson, in: tableView, at: indexPath)
        default: fatalError()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:     return nil
        // TODO: Localize properly.
        case 1:     return NSLocalizedString("Lessons", comment: "")
        default:    return nil
        }
    }
}
