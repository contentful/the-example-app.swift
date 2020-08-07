
import Foundation
import UIKit
import Alamofire
import AlamofireImage
import Contentful

class LessonImageTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = LessonImage

    func configure(item: LessonImage) {
        guard let asset = item.image else {
            return
        }
        imageCaptionLabel.text = item.caption
        lessonImageView.setImageToNaturalHeight(fromAsset: asset, heightConstraint: lessonImageHeightConstraint)
    }

    func resetAllContent() {
        lessonImageView.image = nil
        lessonImageHeightConstraint.constant = 0.0
        imageCaptionLabel.text = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = false
        selectionStyle = .none
    }

    @IBOutlet weak var lessonImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lessonImageView: UIImageView!

    @IBOutlet weak var imageCaptionLabel: UILabel! {
        didSet {
            imageCaptionLabel.font = UIFont.italicSystemFont(ofSize: 14.0)
        }
    }
}
