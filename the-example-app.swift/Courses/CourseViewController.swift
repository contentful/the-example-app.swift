
import Foundation
import UIKit

class CourseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var course: Course?

    var services: Services

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

    let courseOverviewCellFactory = TableViewCellFactory<CourseOverviewTableViewCell>()
    let lessonCellFactory = TableViewCellFactory<LessonTableViewCell>()

    init(course: Course, services: Services) {
        self.course = course
        self.services = services
        super.init(nibName: nil, bundle: nil)

        self.hidesBottomBarWhenPushed = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func didTapStartCourseButton(_ sender: Any) {
        pushLessonsCollectionViewAndShowLesson(at: 0)
    }

    func pushLessonsCollectionViewAndShowLesson(at index: Int) {
        guard let course = course else { return }
        let lessonViewController = LessonsCollectionViewController(course: course, services: services)
        lessonViewController.onLoad = {
            // TODO: Better API.
            lessonViewController.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
        navigationController?.pushViewController(lessonViewController, animated: true)
    }

    @IBOutlet weak var startCourseButton: UIButton! {
        didSet {
            // Set font etc here.
        }
    }

    // MARK: UIViewController

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.registerNibFor(CourseOverviewTableViewCell.self)
        tableView.registerNibFor(LessonTableViewCell.self)

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
