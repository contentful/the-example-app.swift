//
//  LessonRichTextTableViewCell.swift
//  the-example-app.swift
//
//  Created by JP Wright on 13/12/18.
//  Copyright © 2018 Contentful. All rights reserved.
//

import Foundation
import Contentful
import ContentfulRichTextRenderer

class LessonRichTextTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = LessonCollectionViewCell.Model

    var cellViewModel: ItemType?

    var richTextViewController: RichTextViewController?

    func configure(item: LessonCollectionViewCell.Model) {
        cellViewModel = item
        richTextViewController = RichTextViewController(richText: cellViewModel!.lesson.richText,
                                                        renderer: nil,
                                                        nibName: nil,
                                                        bundle: nil)
    }

    func resetAllContent() {
        richTextViewController = nil
        cellViewModel = nil
    }
}
