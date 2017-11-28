
import Foundation
import UIKit

class HighlightedCourseTableViewCell: UITableViewCell, CellConfigurable {

    func configure(item: HighlightedCourse) {
        titleLabel.text = item.course?.title
        descriptionLabel.text = item.course?.courseDescription
    }

    @IBOutlet weak var titleLabel: UILabel! { didSet {} }
    @IBOutlet weak var descriptionLabel: UILabel! { didSet {} }
}
