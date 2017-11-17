

import Foundation
import UIKit

class CourseTableViewCell: UITableViewCell, TableViewCellModel {

    typealias ItemType = Course

    func configure(item: Course) {
        titleLabel.text = item.title
        shortDescriptionLabel.text = item.shortDescription
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            // Set font etc here.
        }
    }

    @IBOutlet weak var shortDescriptionLabel: UILabel! {
        didSet {
            // Set font etc here.
        }
    }
}
