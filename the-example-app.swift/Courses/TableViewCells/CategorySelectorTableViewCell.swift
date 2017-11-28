
import Foundation
import UIKit

protocol CategorySelectorDelegate {

    func didSelectCategory(_ category: Category?)
}

class CategorySelectorTableViewCell: UITableViewCell, CellConfigurable, UICollectionViewDataSource, UICollectionViewDelegate {

    struct Model {
        var categories: [Category]?
        var delegate: CategorySelectorDelegate
        var selectedCategory: Category?
    }

    var delegate: CategorySelectorDelegate?
    var categories: [Category]?

    let categoryCellFactory = CollectionViewCellFactory<CategoryCollectionViewCell>()

    @IBOutlet weak var categoriesCollectionView: UICollectionView! {
        didSet {
            categoriesCollectionView.registerNibFor(CategoryCollectionViewCell.self)
        }
    }

    func configure(item: Model) {
        self.categories = item.categories
        self.delegate = item.delegate

        if let selectedCategory = item.selectedCategory, let rowIndex = item.categories?.index(of: selectedCategory) {
            if categoriesCollectionView.numberOfItems(inSection: 1) > 0 {
                let row = Int(rowIndex)
                let indexPath = IndexPath(row: row, section: 1)
                categoriesCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
        } else {
            if categoriesCollectionView.numberOfItems(inSection: 0) > 0 {
                let indexPath = IndexPath(row: 0, section: 0)
                categoriesCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }

        }

        // TODO:
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.delegate = self
        categoriesCollectionView.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:     return 1
        case 1:     return categories?.count ?? 0
        default:    return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch indexPath.section {
        case 0:
            // TODO: Localize text
            cell = categoryCellFactory.cell(for: "All Courses", in: collectionView, at: indexPath)
        case 1:
            guard let category = categories?[indexPath.item] else {
                fatalError("TODO")
            }
            cell = categoryCellFactory.cell(for: category.title, in: collectionView, at: indexPath)
        default: fatalError("TODO")
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:     delegate?.didSelectCategory(nil)
        case 1:     delegate?.didSelectCategory(categories?[indexPath.item])
        default:    fatalError("TODO")
        }
    }
}
