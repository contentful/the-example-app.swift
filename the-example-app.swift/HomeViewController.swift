//
//import Foundation
//import UIKit
//import Contentful
//
//
//class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    @objc dynamic var homeLayout: HomeLayout?
//
//    let contentful: contentful
//
//    var homeObservation: NSKeyValueObservation?
//
//    var tableView: UITableView!
//
//    var tableViewDataSource: UITableViewDataSource? {
//        didSet {
//            DispatchQueue.main.async { [weak self] in
//                self?.tableView.dataSource = self!.tableViewDataSource
//                self?.tableView.reloadData()
//            }
//        }
//    }
//
//    func query() -> QueryOn<HomeLayout> {
//        return QueryOn<HomeLayout>.where(field: .slug, .equals("home"))
//    }
//
//    init(contentful: contentful) {
//        self.contentful = contentful
//        super.init(nibName: nil, bundle: nil)
//        self.tabBarItem = UITabBarItem(title: "Home", image: nil, selectedImage: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func fetchLayoutFromContenful() {
//        contentful.client().fetchMappedEntries(matching: query()) { [weak self] result in
//            switch result {
//            case .success(let arrayResponse):
//                self?.homeLayout = arrayResponse.items.first!
//                self?.tableViewDataSource = self
//
//            case .error(let error):
//                // TODO:
//                print(error)
//                self?.tableViewDataSource = ErrorTableViewDataSource(error: error)
//            }
//        }
//    }
//
//    // MARK: UIViewController
//
//    override func loadView() {
//        tableView = UITableView(frame: .zero)
//
//        tableView.register(CopyTableViewCell.self)
//        tableView.register(HighlightedCourseTableViewCell.self)
//        tableView.registerNibFor(LoadingTableViewCell.self)
//        tableView.register(ErrorTableViewCell.self)
//
//        // Enable table view cells to be sized dynamically based on inner content.
//        tableView.rowHeight = UITableViewAutomaticDimension
//        view = tableView
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        tableViewDataSource = LoadingTableViewDataSource()
//        tableView.delegate = self
//
//        fetchLayoutFromContenful()
//        
//        // Update the tableView when we get a lesson back.
//        homeObservation = self.observe(\.homeLayout) { [weak self] _, newLayout in
//            DispatchQueue.main.async {
//                self?.tableView.reloadData()
//            }
//        }
//    }
//
//    
//    // MARK: UITableViewDataSource
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return homeLayout?.modules?.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let module = homeLayout?.modules?[indexPath.item] as? Module else {
//            fatalError("TODO")
//        }
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: module.viewType), for: indexPath)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let cell = cell as? ModuleView else {
//            return
//        }
//
//        cell.update(module: homeLayout!.modules![indexPath.item])
//    }
//}

