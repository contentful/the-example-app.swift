
import UIKit
import Contentful




class LessonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // `lesson` is @objc dynamic to take advantage of the key-value observation mechanism in Swift 4.
    @objc dynamic var lesson: Lesson?

    var lessonObservation: NSKeyValueObservation?

    var tableView: UITableView!

    var tableViewDataSource: UITableViewDataSource? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.dataSource = self!.tableViewDataSource
                self?.tableView.reloadData()
            }
        }
    }

    init(lesson: Lesson?) {
        self.lesson = lesson
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.registerNibFor(LessonCopyTableViewCell.self)
        tableView.register(LessonSnippetsTableViewCell.self)
        tableView.register(LessonImageTableViewCell.self)

        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        // Update the tableView when we get a lesson back.
        lessonObservation = self.observe(\.lesson) { [weak self] _, newLesson in
            self?.tableView.reloadData()
        }
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lesson?.modules?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if let markdownModule = lesson?.modules?[indexPath.item] as? LessonCopy {
            cell = TableViewCellFactory<LessonCopyTableViewCell>().cell(for: markdownModule, in: tableView, at: indexPath)

        } else if let snippetsModule = lesson?.modules?[indexPath.item] as? LessonSnippets {
            cell = TableViewCellFactory<LessonSnippetsTableViewCell>().cell(for: snippetsModule, in: tableView, at: indexPath)

        } else if let imageModule = lesson?.modules?[indexPath.item] as? LessonImage {
            cell = TableViewCellFactory<LessonImageTableViewCell>().cell(for: imageModule, in: tableView, at: indexPath)

        } else {
            fatalError("TODO")
        }
        return cell
    }
}

