
import Foundation
import UIKit

final class LessonCollectionViewCell: UICollectionViewCell, CellConfigurable {

    struct Model {
        let lesson: Lesson
        let services: Services
        var addChildViewController: (UIViewController, UITableViewCell) -> Void
        var removeChildViewController: (UIViewController) -> Void
    }

    // The lesson is optional so that we can deep link to a cell and show a loading state.
    typealias ItemType = Model?

    func configure(item: Model?) {
        if let item = item {
            let dataSource = LessonModulesDataSource(lessonViewModel: item)
            accessibilityLabel = item.lesson.title
            tableViewDataSource = dataSource
            tableView.delegate = dataSource
        } else {
            tableViewDataSource = LoadingTableViewDataSource()
            tableView.delegate = nil
        }
    }

    func resetAllContent() {
        accessibilityLabel = nil

        tableViewDataSource = nil
        tableView.delegate = nil
    }

    var tableViewDataSource: UITableViewDataSource? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.dataSource = self?.tableViewDataSource
                self?.tableView?.reloadData()
            }
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.separatorStyle = .none
            tableView.separatorColor = .clear

            tableView.registerNibFor(LoadingTableViewCell.self)
            tableView.registerNibFor(ErrorTableViewCell.self)
            tableView.registerNibFor(ResourceStatesTableViewCell.self)
            tableView.registerNibFor(LessonRichTextTableViewCell.self)
        }
    }
}

class LessonModulesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    let lessonViewModel: LessonCollectionViewCell.Model

    let stateCellFactory = TableViewCellFactory<ResourceStatesTableViewCell>()

    let richTextCellFactory = TableViewCellFactory<LessonRichTextTableViewCell>()

    init(lessonViewModel: LessonCollectionViewCell.Model) {
        self.lessonViewModel = lessonViewModel
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if lessonViewModel.services.contentful.shouldShowResourceStateLabels && lessonViewModel.lesson.state != .upToDate {
                return 1
            }
            return 0
        case 1:
            return 1
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? LessonRichTextTableViewCell, let viewController = cell.richTextViewController else { return }
        cell.cellViewModel?.addChildViewController(viewController, cell)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? LessonRichTextTableViewCell, let viewController = cell.richTextViewController else { return }
        cell.cellViewModel?.removeChildViewController(viewController)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return stateCellFactory.cell(for: lessonViewModel.lesson.state, in: tableView, at: indexPath)
        case 1:
            return richTextCellFactory.cell(for: lessonViewModel, in: tableView, at: indexPath)
        default:
            fatalError()
        }
    }
}
