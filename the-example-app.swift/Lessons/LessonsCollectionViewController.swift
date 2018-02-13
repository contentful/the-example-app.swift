
import Foundation
import UIKit

class LessonsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CustomNavigable {

    init(course: Course?, services: Services) {
        self.course = course
        self.services = services
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
        state = course == nil ? .showLoading : .showLesson
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var course: Course? {
        didSet {
            state = course == nil ? .showLoading : .showLesson
            DispatchQueue.main.async { [weak self] in
                guard let collectionView = self?.collectionView else { return }
                collectionView.reloadData()
            }
        }
    }

    var services: Services

    var collectionView: UICollectionView!

    var cellFactory = CollectionViewCellFactory<LessonCollectionViewCell>()

    var onAppear: (() -> Void)?

    public func updateLessonStateAtIndex(_ index: Int) {
        DispatchQueue.main.async { [weak self] in
            let indexPath = IndexPath(row: index, section: 0)
            self?.collectionView.reloadItems(at: [indexPath])
        }
    }

    enum State {
        case showLoading
        case showLesson
    }

    var state: State = .showLoading

    public func update(showLoadingState: Bool = false) {
        if showLoadingState {
            state = .showLoading
            return
        }
        guard let lesson = currentlyVisibleLesson() else {
            return
        }
        showLessonWithSlug(lesson.slug)
    }

    public func showLessonWithSlug(_ slug: String) {
        if let lessonIndex = course?.lessons?.index(where: { $0.slug == slug }) {
            let indexPath = IndexPath(item: lessonIndex, section: 0)
            if let collectionView = collectionView {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            } else {
                // If the collectionView hasn't been loaded yet, let's add a callback to execute later.
                onAppear = { [weak self] in
                    self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                }
            }
            return
        }
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }

    func updateToolbarItems(newIndexPath: IndexPath) {
        var toolbarItems = [UIBarButtonItem]()
        if newIndexPath.row != 0 {
            let previousLessonButton = UIBarButtonItem(title: NSLocalizedString("Previous", comment: ""), style: .plain, target: self, action: #selector(LessonsCollectionViewController.didTapPreviousLessonButton(_:)))
            toolbarItems.append(previousLessonButton)
        }

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems.append(flexibleSpace)

        if let lessonCount = course?.lessons?.count, newIndexPath.row != lessonCount - 1 {
            let nextLessonButton = UIBarButtonItem(title: "Next".localized(contentfulService: services.contentful), style: .plain, target: self, action: #selector(LessonsCollectionViewController.didTapNextLessonButton(_:)))
            toolbarItems.append(nextLessonButton)
        }
        setToolbarItems(toolbarItems, animated: true)
    }

    func updateNavBarTitle(lessonIndex: Int) {
        if let lesson = course?.lessons?[lessonIndex] {
            self.title = lesson.title
        }
    }

    // MARK: CustomNavigable
    
    var hasCustomToolbar: Bool {
        return true
    }

    var prefersLargeTitles: Bool {
        return false
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

    deinit {
        print("dealloc LessonsCollectionViewController")
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
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onAppear?()
        onAppear = nil
    }

    func currentlyVisibleLesson() -> Lesson? {
        if let indexPath = collectionView.indexPathsForVisibleItems.first {
            let lesson = course?.lessons?[indexPath.item]
            return lesson
        }
        return nil
    }

    @objc func didTapNextLessonButton(_ sender: Any) {
        guard let lessons = course?.lessons else { return }
        if let indexPath = collectionView.indexPathsForVisibleItems.first, indexPath.row < lessons.count - 1 {
            let newIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
        }
    }

    @objc func didTapPreviousLessonButton(_ sender: Any) {
        guard course?.lessons != nil else { return }
        if let indexPath = collectionView.indexPathsForVisibleItems.first, indexPath.row > 0 {
            let newIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
        }
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return course?.lessons?.count ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell

        switch state {
        case .showLesson where course?.lessons?[indexPath.item] != nil:
            let lesson = course!.lessons![indexPath.item]
            let lessonViewModel = LessonViewModel(showsResourceStatePills: services.contentful.shouldShowResourceStateLabels, lesson: lesson)
            cell = cellFactory.cell(for: lessonViewModel, in: collectionView, at: indexPath)

        default:
            // Render a cell that will just have a table view showing a loading spinner.
            cell = cellFactory.cell(for: nil, in: collectionView, at: indexPath)
        }
        return cell
    }

    // MARK: UICollectionViewDelegete

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        updateNavBarTitle(lessonIndex: indexPath.row)
        updateToolbarItems(newIndexPath: indexPath)
        if let course = self.course, let lesson = course.lessons?[indexPath.row], state == .showLesson {
            Analytics.shared.logViewedRoute("/courses/\(course.slug)/lessons/\(lesson.slug)", spaceId: services.contentful.spaceId)
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
}
