
import Foundation
import UIKit

final class LessonCollectionViewCell: UICollectionViewCell, CellConfigurable {

    typealias ItemType = Lesson

    func configure(item: Lesson) {
        self.tableViewDataSource = LessonModulesDataSource(lesson: item)
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
            tableView.registerNibFor(LessonCopyTableViewCell.self)
            tableView.register(LessonSnippetsTableViewCell.self)
            tableView.register(LessonImageTableViewCell.self)
        }
    }
}

class LessonModulesDataSource: NSObject, UITableViewDataSource {

    let lesson: Lesson

    let copyCellFactory = TableViewCellFactory<LessonCopyTableViewCell>()
    let snippetsCellFactory = TableViewCellFactory<LessonSnippetsTableViewCell>()
    let imageCellFactory = TableViewCellFactory<LessonImageTableViewCell>()


    init(lesson: Lesson) {
        self.lesson = lesson
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lesson.modules?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if let markdownModule = lesson.modules?[indexPath.item] as? LessonCopy {
            cell = copyCellFactory.cell(for: markdownModule, in: tableView, at: indexPath)

        } else if let snippetsModule = lesson.modules?[indexPath.item] as? LessonSnippets {
            cell = snippetsCellFactory.cell(for: snippetsModule, in: tableView, at: indexPath)

        } else if let imageModule = lesson.modules?[indexPath.item] as? LessonImage {
            cell = imageCellFactory.cell(for: imageModule, in: tableView, at: indexPath)

        } else {
            fatalError("TODO")
        }
        return cell
    }
}

extension LessonModule {

}
