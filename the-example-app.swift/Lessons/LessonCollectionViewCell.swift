
import Foundation
import UIKit


struct LessonViewModel {

    let editorialFeatures: EditorialFeatures
    let lesson: Lesson

    enum EditorialFeatures {
        case none
        case showEditButton
        case showStateAndEditButton
    }
}

final class LessonCollectionViewCell: UICollectionViewCell, CellConfigurable {

    // The lesson is optional so that we can deep link to a cell and show a loading state.
    typealias ItemType = LessonViewModel?

    func configure(item: LessonViewModel?) {
        if let item = item {
            self.tableViewDataSource = LessonModulesDataSource(lessonViewModel: item)
        } else {
            self.tableViewDataSource = LoadingTableViewDataSource()
        }
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
            
            tableView.registerNibFor(ModuleOwnerStateTableViewCell.self)
        }
    }
}

class LessonModulesDataSource: NSObject, UITableViewDataSource {

    let lessonViewModel: LessonViewModel

    let stateCellFactory = TableViewCellFactory<ModuleOwnerStateTableViewCell>()

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
            if lessonViewModel.editorialFeatures == .none {
                return 0
            }
            return 1
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
            fatalError("TODO")
        }
        return cell
    }
}
