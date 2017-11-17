//
//  ViewController.swift
//  TestMarkdown
//
//  Created by JP Wright on 02.11.17.
//  Copyright © 2017 Contentful. All rights reserved.
//

import UIKit
import Contentful
import Down

class LessonViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // `lesson` is @objc dynamic to take advantage of the key-value observation mechanism in Swift 4.
    @objc dynamic var lesson: Lesson?

    var lessonObservation: NSKeyValueObservation?

    let contentfulService: ContentfulService

    var tableView: UITableView!

    var tableViewDataSource: UITableViewDataSource? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.dataSource = self!.tableViewDataSource
                self?.tableView.reloadData()
            }
        }
    }

    init(contentfulService: ContentfulService, lesson: Lesson?) {
        self.lesson = lesson
        self.contentfulService = contentfulService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.register(CopyTableViewCell.self)
        tableView.register(LessonSnippetsTableViewCell.self)
        tableView.register(LessonImageTableViewCell.self)

        // Enable table view cells to be sized dynamically based on inner content.
        tableView.rowHeight = UITableViewAutomaticDimension
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        // Update the tableView when we get a lesson back.
        lessonObservation = self.observe(\.lesson) { [weak self] _, newLesson in
            self?.tableView.reloadData()
        }

        navigationController?.toolbar.barStyle = .default
        navigationController?.isToolbarHidden = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let nextLessonButton = UIBarButtonItem(title: NSLocalizedString("nextLessonLabel", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(LessonViewController.didTapNextLessonButton(_:)))
        toolbarItems = [flexibleSpace, nextLessonButton]
    }

    @objc func didTapNextLessonButton(_ sender: Any) {
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lesson?.modules?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let module = lesson?.modules?[indexPath.item] as? RenderableEntry else {
            fatalError("TODO")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: module.viewType), for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ModuleView else {
            fatalError("TODO")
        }

        cell.update(module: lesson!.modules![indexPath.item])
    }


}









