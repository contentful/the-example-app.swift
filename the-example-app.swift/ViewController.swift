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
import Keys

extension UITableView {
    func register(_ type: UITableViewCell.Type) {
        let typeName = String(describing: type)
        register(type, forCellReuseIdentifier: typeName)
    }
}

class LessonViewController: UIViewController,
                            UITableViewDataSource,
                            UITableViewDelegate {

    var client: Client!
    var tableView: UITableView!

    var lesson: Lesson?

    override func loadView() {
        tableView = UITableView(frame: .zero)

        tableView.register(LessonCopyTableViewCell.self)
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

        let contentTypeClasses: [EntryDecodable.Type] = [
            Lesson.self,
            LessonCopy.self,
            LessonImage.self,
            LessonSnippets.self
        ]

        let apiKeys = TheExampleAppSwiftKeys()

        client = Client(spaceId: apiKeys.spaceId,
                        accessToken: apiKeys.deliveryAPIAccessToken,
                        contentTypeClasses: contentTypeClasses)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchContentfulDataAndFillMarkdown()
    }

    func fetchContentfulDataAndFillMarkdown() {
        let query = QueryOn<Lesson>.where(sys: .id, .equals("5mgMoU9aCWE88SIqSIMGYE")).include(1)
        
        client.fetchMappedEntries(matching: query) { result in
            switch result {
            case .success(let response):
                self.lesson = response.items.first!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .error:
                fatalError()
            }
        }
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lesson?.modules?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let module = lesson?.modules?[indexPath.item] as? RenderableLessonModule else {
            fatalError("TODO")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: module.viewType), for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? Renderable else {
            fatalError("TODO")
        }

        cell.update(module: lesson!.modules![indexPath.item])
    }
}

protocol Renderable {
    func update(module: LessonModule)
}

class LessonCopyTableViewCell: UITableViewCell, Renderable {
    func update(module: LessonModule) {
        guard let module = module as? LessonCopy else {
            fatalError()
        }

        guard let downView = try? DownView(frame: self.contentView.bounds, markdownString: module.copy, didLoadSuccessfully: {
            // Optional callback for loading finished
            print("Markdown was rendered.")
        }) else { return }
        downView.scrollView.isScrollEnabled = false

        contentView.addSubview(downView)
        contentView.setNeedsLayout()

    }
}

class LessonSnippetsTableViewCell: UITableViewCell, Renderable {
    func update(module: LessonModule) {
        guard let module = module as? LessonSnippets else {
            fatalError()
        }

        guard let downView = try? DownView(frame: self.contentView.bounds, markdownString: module.swift, didLoadSuccessfully: {
            // Optional callback for loading finished
            print("Markdown was rendered.")
        }) else { return }
        downView.scrollView.isScrollEnabled = false

        contentView.addSubview(downView)
        contentView.setNeedsLayout()
    }
}

class LessonImageTableViewCell: UITableViewCell, Renderable {
    func update(module: LessonModule) {
        guard let module = module as? LessonImage else {
            fatalError()
        }

//        guard let downView = try? DownView(frame: self.contentView.bounds, markdownString: module.copy, didLoadSuccessfully: {
//            // Optional callback for loading finished
//            print("Markdown was rendered.")
//        }) else { return }
//        downView.scrollView.isScrollEnabled = false
//
//        contentView.addSubview(downView)
//        contentView.setNeedsLayout()

    }
}









