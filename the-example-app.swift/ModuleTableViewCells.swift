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

