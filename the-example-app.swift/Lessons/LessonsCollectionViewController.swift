
import Foundation
import UIKit

class LessonsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var course: Course? {
        didSet {
            DispatchQueue.main.sync {
                collectionView?.reloadData()
            }
        }
    }

    var services: Services

    var collectionView: UICollectionView!

    var cellFactory = CollectionViewCellFactory<LessonCollectionViewCell>()

    var onLoad: (() -> Void)?

    init(course: Course?, services: Services) {
        self.course = course
        self.services = services
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: UIViewController

    override func loadView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.registerNibFor(LessonCollectionViewCell.self)

        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.scrollsToTop = false

        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

        // Offset collection view to make space for navigation and tab bars.
        collectionView.contentInsetAdjustmentBehavior = .never

        // Configure the bottom toolbar.
        navigationController?.toolbar.barStyle = .default
        navigationController?.isToolbarHidden = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let nextLessonButton = UIBarButtonItem(title: NSLocalizedString("nextLessonLabel", comment: ""), style: .plain, target: self, action: #selector(LessonsCollectionViewController.didTapNextLessonButton(_:)))
        toolbarItems = [flexibleSpace, nextLessonButton]
    }

    public func showLessonWithSlug(_ slug: String) {
        if let lessonIndex = course?.lessons?.index(where: { $0.slug == slug }) {
            let indexPath = IndexPath(item: lessonIndex, section: 0)
            if let collectionView = collectionView {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            } else {
                onLoad = { [weak self] in
                    self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                }
            }
            return
        }
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onLoad?()
    }
    
    @objc func didTapNextLessonButton(_ sender: Any) {
        if let indexPath = collectionView.indexPathsForVisibleItems.first {
            let newIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
        }
    }


    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return course?.lessons?.count ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        if let lesson = course?.lessons?[indexPath.item] {
            cell = cellFactory.cell(for: lesson, in: collectionView, at: indexPath)
        } else {
            // Render a cell that will just have a table view showing a loading spinner.
            cell = cellFactory.cell(for: nil, in: collectionView, at: indexPath)
        }

        return cell
    }


    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
}
