
import Foundation
import UIKit
import Alamofire
import AlamofireImage
import Contentful

class LessonImageTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = LessonImage


    func configure(item: LessonImage) {
        guard let asset = item.image else {
            // TODO: Set placeholder image
            return
        }

        lessonImageView.setImageToNaturalHeight(fromAsset: asset, heightConstraint: lessonImageHeightConstraint)
    }

    func resetAllContent() {
        lessonImageView.image = nil
        lessonImageHeightConstraint.constant = 0.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = false
        selectionStyle = .none
    }

    @IBOutlet weak var lessonImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lessonImageView: UIImageView!
}
