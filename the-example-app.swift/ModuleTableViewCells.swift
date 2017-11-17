
import Foundation
import UIKit
import markymark


protocol TableViewCellModel {

    associatedtype ItemType

    func configure(item: ItemType)
}


class HeroImageTableViewCell: UITableViewCell {

}

class HighlightedCourseTableViewCell: UITableViewCell {

    func update(module: Module) {}

}



class LessonSnippetsTableViewCell: UITableViewCell, TableViewCellModel {

    typealias ItemType = LessonSnippets

    func configure(item: LessonSnippets) {
    }
}

class LessonImageTableViewCell: UITableViewCell, TableViewCellModel {

    typealias ItemType = LessonImage

    func necessaryHeight() -> CGFloat {
        // TODO:
        return 0.0
    }
    func configure(item: LessonImage) {
        // TODO: 
    }
}
