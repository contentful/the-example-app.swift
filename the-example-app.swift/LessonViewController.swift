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

    let contentfulProvider: ContentfulProvider

    var tableView: UITableView!

    init(contentfulProvider: ContentfulProvider) {
        self.contentfulProvider = contentfulProvider
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lesson?.modules?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let module = lesson?.modules?[indexPath.item] as? RenderableModule else {
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









