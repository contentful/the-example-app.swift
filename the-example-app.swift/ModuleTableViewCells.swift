
import Foundation
import UIKit
import markymark



class HeroImageTableViewCell: UITableViewCell {
}

class HighlightedCourseTableViewCell: UITableViewCell {

    func update(module: Module) {}

}



class LessonSnippetsTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = LessonSnippets

    func configure(item: LessonSnippets) {}
}

class LessonImageTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = LessonImage

    func configure(item: LessonImage) {
        // TODO: 
    }
}
