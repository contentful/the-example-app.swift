
import Foundation
import UIKit

struct LessonViewModel {

    let showsResourceStatePills: Bool
    let lesson: Lesson
}

final class LessonCollectionViewCell: UICollectionViewCell, CellConfigurable {

    // The lesson is optional so that we can deep link to a cell and show a loading state.
    typealias ItemType = LessonViewModel?

    func configure(item: LessonViewModel?) {
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
            tableView.registerNibFor(LessonCopyTableViewCell.self)
            tableView.registerNibFor(LessonSnippetsTableViewCell.self)
            tableView.registerNibFor(LessonImageTableViewCell.self)
            
            tableView.registerNibFor(ResourceStatesTableViewCell.self)
        }
    }
}

class LessonModulesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    let lessonViewModel: LessonViewModel

    let stateCellFactory = TableViewCellFactory<ResourceStatesTableViewCell>()

    let copyCellFactory = TableViewCellFactory<LessonCopyTableViewCell>()
    let snippetsCellFactory = TableViewCellFactory<LessonSnippetsTableViewCell>()
    let imageCellFactory = TableViewCellFactory<LessonImageTableViewCell>()

    init(lessonViewModel: LessonViewModel) {
        self.lessonViewModel = lessonViewModel
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if lessonViewModel.showsResourceStatePills {
                return 1
            }
            return 0
        case 1:
            return lessonViewModel.lesson.modules?.count ?? 0
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return stateCellFactory.cell(for: lessonViewModel.lesson.state, in: tableView, at: indexPath)
        case 1:
            return cellInModulesSection(tableView: tableView, indexPath: indexPath)
        default:
            fatalError()
        }
    }

    func cellInModulesSection(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if let markdownModule = lessonViewModel.lesson.modules?[indexPath.item] as? LessonCopy {
            cell = copyCellFactory.cell(for: markdownModule, in: tableView, at: indexPath)

        } else if let snippetsModule = lessonViewModel.lesson.modules?[indexPath.item] as? LessonSnippets {
            cell = snippetsCellFactory.cell(for: snippetsModule, in: tableView, at: indexPath)

        } else if let imageModule = lessonViewModel.lesson.modules?[indexPath.item] as? LessonImage {
            cell = imageCellFactory.cell(for: imageModule, in: tableView, at: indexPath)

        } else {
            fatalError()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if lessonViewModel.lesson.state == .upToDate {
                return 0.0
            }
            return UITableViewAutomaticDimension
        case 1:
            return UITableViewAutomaticDimension
        default:
            fatalError()
        }
    }
}
