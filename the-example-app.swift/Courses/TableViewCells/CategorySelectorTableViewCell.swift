
import Foundation
import UIKit

protocol CategorySelectorDelegate {

    func didSelectCategory(_ category: Category?)
}

class CategorySelectorTableViewCell: UITableViewCell, CellConfigurable, UICollectionViewDataSource, UICollectionViewDelegate {

    struct Model {
        let contentfulService: ContentfulService
        var categories: [Category]?
        var delegate: CategorySelectorDelegate
        var selectedCategory: Category?
    }

    var viewModel: Model?

    let categoryCellFactory = CollectionViewCellFactory<CategoryCollectionViewCell>()

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    func configure(item: Model) {
        viewModel = item
        reloadCollectionView()
        updateSelectedCategory(item: item)
    }

    func resetAllContent() {
        viewModel = nil
        collectionView.dataSource = nil
        collectionView.delegate = nil
    }

    func reloadCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    func updateSelectedCategory(item: Model) {
        if let selectedCategory = item.selectedCategory, let rowIndex = item.categories?.index(of: selectedCategory) {
            guard collectionView.numberOfItems(inSection: 1) > 0 else { return }
            let indexPath = IndexPath(row: Int(rowIndex), section: 1)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)

        } else {
            guard collectionView.numberOfItems(inSection: 0) > 0 else { return }
            let indexPath = IndexPath(row: 0, section: 0)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
    }

    // MARK: UIView

    override func awakeFromNib() {
        super.awakeFromNib()

        // We must set the autoresizeing mask so that the layout constraints don't break
        // https://stackoverflow.com/a/26208528/4068264
        contentView.autoresizingMask = .flexibleHeight
        selectionStyle = .none
        collectionView.registerNibFor(CategoryCollectionViewCell.self)
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: 100, height: 50)
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:     return 1
        case 1:     return viewModel?.categories?.count ?? 0
        default:    return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch indexPath.section {
        case 0:

            cell = categoryCellFactory.cell(for: "allCoursesLabel".localized(contentfulService: viewModel!.contentfulService), in: collectionView, at: indexPath)
        case 1:
            guard let category = viewModel?.categories?[indexPath.item] else {
                fatalError()
            }
            cell = categoryCellFactory.cell(for: category.title, in: collectionView, at: indexPath)
        default: fatalError()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch indexPath.section {
        case 0:     viewModel?.delegate.didSelectCategory(nil)
        case 1:     viewModel?.delegate.didSelectCategory(viewModel?.categories?[indexPath.item])
        default:    fatalError()
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
