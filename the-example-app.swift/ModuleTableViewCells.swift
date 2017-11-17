//
//  ModuleTableViewCells.swift
//  the-example-app.swift
//
//  Created by JP Wright on 14.11.17.
//  Copyright © 2017 Contentful. All rights reserved.
//

import Foundation
import UIKit
import Down


protocol TableViewCellModel {

    associatedtype ItemType

    func configure(item: ItemType)
}


protocol CourseView {
    func update(course: Course)
}

protocol ModuleView {
    func update(module: Module)
}

class HeroImageTableViewCell: UITableViewCell, ModuleView {
    // TODO:
    func update(module: Module) {}

}

class HighlightedCourseTableViewCell: UITableViewCell, ModuleView {

    func update(module: Module) {
        guard let module = module as? HighlightedCourse else {
            fatalError()
        }

        print("Great success")
    }
}


class CopyTableViewCell: UITableViewCell, ModuleView {

    func update(module: Module) {
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

class LessonSnippetsTableViewCell: UITableViewCell, ModuleView {
    func update(module: Module) {
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

class LessonImageTableViewCell: UITableViewCell, ModuleView {
    func update(module: Module) {
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

