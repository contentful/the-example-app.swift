
import Foundation
import UIKit
import Contentful
import Interstellar

class CourseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomNavigable {

    init(course: Course?, services: Services) {
        self.course = course
        self.services = services
        super.init(nibName: nil, bundle: nil)

        self.hidesBottomBarWhenPushed = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: Refactor to use the result type.
    private var course: Course? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                if self?.course != nil {
                    self?.tableView?.delegate = self
                    self?.resolveStateOnLessons()
                } else {
                    // Just show the loading spinner.
                    // TODO: Handle error?
                    self?.tableView.delegate = nil
                    self?.tableView?.reloadData()
                }
            }
        }
    }

    var services: Services

    var tableView: UITableView! 

    /**
     * The lessons collection view controller for a course that is currenlty pushed onto the navigation stack.
     * This property is declared as weak so that when the navigaton controller pops the course view controller
     * it will not be retained here.
     */
    weak var lessonsViewController: LessonsCollectionViewController?

    // We must retain the data source.
    var tableViewDataSource: UITableViewDataSource? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView?.dataSource = self!.tableViewDataSource
                self?.tableView?.reloadData()
            }
        }
    }

    let courseOverviewCellFactory = TableViewCellFactory<CourseOverviewTableViewCell>()
    let lessonCellFactory = TableViewCellFactory<LessonTableViewCell>()

    // MARK: CustomNavigable
    
    var hasCustomToolbar: Bool {
        return false
    }

    var prefersLargeTitles: Bool {
        return false
    }


    // Contentful query.
    func query(slug: String) -> QueryOn<Course> {
        let localeCode = services.contentful.currentLocaleCode
        let query = QueryOn<Course>.where(field: .slug, .equals(slug)).include(3).localizeResults(withLocaleCode: localeCode)
        return query
    }

    // Request.
    var courseRequest: URLSessionTask?

    func updateAPI() {
        guard let course = course else { return }
        fetchCourseWithSlug(course.slug)
    }

    func updateEditorialFeatures() {
        guard let course = course else { return }
        fetchCourseWithSlug(course.slug)
    }

    func updateLocale() {
        guard let course = course else { return }
        fetchCourseWithSlug(course.slug)
    }

    // This method is called by Router when deeplinking into a course and/or lesson.
    public func fetchCourseWithSlug(_ slug: String, showLessonWithSlug lessonSlug: String? = nil) {
        tableViewDataSource = LoadingTableViewDataSource()

        updateLessonsController(showLoadingState: true)
        courseRequest?.cancel()
        courseRequest = services.contentful.client.fetchMappedEntries(matching: query(slug: slug)) { [weak self] result in
            self?.courseRequest = nil
            switch result {
            case .success(let arrayResponse):
                if arrayResponse.items.count == 0 {
                    // TODO: Show error.
                    // TODO: Pop lessonsViewController in the case that we have come from a deep link?
                    return
                }
                self?.course = arrayResponse.items.first
                self?.tableViewDataSource = self

                self?.updateLessonsController()

            case .error:
                // TODO:
                break
            }
        }
    }

    public func pushLessonsCollectionViewAndShowLesson(at index: Int) {
        let lessonsViewController = LessonsCollectionViewController(course: course, services: services)

        lessonsViewController.onAppear = {
            lessonsViewController.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        }
        navigationController?.pushViewController(lessonsViewController, animated: true)
        self.lessonsViewController = lessonsViewController
    }

    public func resolveStateOnCourse() {
        guard let course = self.course else { return }

        services.contentful.resolveStateIfNecessary(for: course) { [weak self] (result: Result<Course>, _) in
            guard let statefulCourse = result.value else { return }
            self?.course = statefulCourse
        }
    }

    public func resolveStateOnLessons() {
        guard let course = self.course, let lessons = course.lessons else { return }

        for lesson in lessons {
            services.contentful.resolveStateIfNecessary(for: lesson) { [weak self] (result: Result<Lesson>, deliveryLesson: Lesson?) in
                guard var statefulPreviewLesson = result.value, let statefulPreviewLessonModules = statefulPreviewLesson.modules else { return }
                guard let strongSelf = self else { return }
                guard let deliveryModules = deliveryLesson?.modules else { return }

                // Aggregate state on the Lesson's by looking at the states on each module in `modules: [LessonModule]?` property and update.
                statefulPreviewLesson = strongSelf.services.contentful.inferStateFromLinkedModuleDiffs(statefulRootAndModules: (statefulPreviewLesson, statefulPreviewLessonModules), deliveryModules: deliveryModules)

                if let index = lessons.index(where: { $0.id == statefulPreviewLesson.id }) {
                    strongSelf.course?.lessons?[index] = statefulPreviewLesson
                    strongSelf.lessonsViewController?.updateLessonStateAtIndex(index)
                }
            }
        }
    }

    func updateLessonsController(showLoadingState: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.lessonsViewController?.course = strongSelf.course
            if let lessonsViewController = strongSelf.lessonsViewController {
                lessonsViewController.update(showLoadingState: showLoadingState)
            }
        }
    }

    deinit {
        print("deinit CourseViewController")
    }

    // MARK: UIViewController


    override func viewDidLoad() {
        super.viewDidLoad()

        services.contentful.apiStateMachine.addTransitionObservation { [weak self] _ in
            self?.updateAPI()
        }

        services.contentful.editorialFeaturesStateMachine.addTransitionObservation { [weak self] _ in
            self?.updateEditorialFeatures()
        }

        services.contentful.localeStateMachine.addTransitionObservation { [weak self] _ in
            self?.updateLocale()
        }
    }

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.registerNibFor(CourseOverviewTableViewCell.self)
        tableView.registerNibFor(LessonTableViewCell.self)
        tableView.registerNibFor(LoadingTableViewCell.self)

        // Enable table view cells to be sized dynamically based on inner content.
        tableView.rowHeight = UITableViewAutomaticDimension
        view = tableView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if course != nil {
            tableViewDataSource = self
            tableView.delegate = self
            resolveStateOnLessons()
        } else {
            // TODO: reload course?
            tableViewDataSource = LoadingTableViewDataSource()
            tableView.delegate = nil
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // If the datasource == self, then we will have a retain cycle, so we must nullify it when off screen.
        tableViewDataSource = nil
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
            let model = CourseOverviewTableViewCell.Model(contentfulService: services.contentful, course: course) { [weak self] in
                self?.pushLessonsCollectionViewAndShowLesson(at: 0)
            }
            cell = courseOverviewCellFactory.cell(for: model, in: tableView, at: indexPath)
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
        case 1:     return "lessonsLabel".localized(contentfulService: services.contentful)
        default:    return nil
        }
    }
}
