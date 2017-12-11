
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

        // Get the current width of the cell and see if it is wider than the screen.
        guard var width = asset.file?.details?.imageInfo?.width else { return }
        guard let height = asset.file?.details?.imageInfo?.height else { return }

        // Use scale to get the pixel size of the image view.
        // TODO: Figure out scale
        let scale = UIScreen.main.scale
        let viewWidthInPx = Double(lessonImageView.frame.width * scale)
        let percentageDifference = viewWidthInPx / width

        // Force the image width to match the width of the frame.
        width = Double(lessonImageView.frame.width / scale)
        let viewHeightInPoints = height * percentageDifference / Double(scale)
        let viewHeightInPx = viewHeightInPoints * Double(scale)

        // Adjust the size of the table view cell.
        lessonImageHeightConstraint.constant = CGFloat(viewHeightInPoints)

        let imageOptions: [ImageOption] = [
            .formatAs(.jpg(withQuality: .asPercent(100))),
            .width(UInt(viewWidthInPx)),
            .height(UInt(viewHeightInPx))
        ]

        do {
            let url = try asset.url(with: imageOptions)

            // Use AlamofireImage extensons to fetch the image and render the image veiw.
            lessonImageView.af_setImage(withURL: url,
                                        placeholderImage: nil,
                                        imageTransition: .crossDissolve(0.5),
                                        runImageTransitionIfCached: true)

        } catch  {
            // TODO:
        }

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = false
        selectionStyle = .none
    }

    @IBOutlet weak var lessonImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lessonImageView: UIImageView!
}
