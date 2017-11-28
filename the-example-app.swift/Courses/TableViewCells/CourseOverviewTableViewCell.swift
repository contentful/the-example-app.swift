
import Foundation
import UIKit

class CourseOverviewTableViewCell: UITableViewCell, CellConfigurable {

    func configure(item: Course) {
        courseTitleLabel.text = item.title
        courseShortDescriptionLabel.text = item.shortDescription
    }

    
    @IBOutlet weak var courseTitleLabel: UILabel! { didSet {} }
    @IBOutlet weak var courseShortDescriptionLabel: UILabel! { didSet {} }
}
