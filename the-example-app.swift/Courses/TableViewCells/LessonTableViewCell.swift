
import Foundation
import UIKit

class LessonTableViewCell: UITableViewCell, CellConfigurable {

    func configure(item: Lesson) {
        lessonTitleLabel.text = item.title
    }

    func resetAllContent() {
        lessonTitleLabel.text = nil
    }

    @IBOutlet weak var lessonTitleLabel: UILabel! { didSet {} }
}
