
import Foundation
import UIKit
import AlamofireImage
import Contentful

class HighlightedCourseTableViewCell: UITableViewCell, CellConfigurable {

    func configure(item: HighlightedCourse) {
        titleLabel.text = item.course?.title
        descriptionLabel.text = item.course?.courseDescription



        guard let asset = item.course?.imageAsset else {
            // TODO: Set placeholder image
            return
        }

        // Get the current width of the cell and see if it is wider than the screen.
        guard var width = asset.file?.details?.imageInfo?.width else { return }
        guard var height = asset.file?.details?.imageInfo?.height else { return }

        // Use scale to get the pixel size of the image view.
        // TODO: Figure out scale
        let scale = UIScreen.main.scale
        let viewWidthInPx = Double(courseImageView.frame.width * scale)
        let percentageDifference = viewWidthInPx / width

        // Force the image width to match the width of the frame.
        width = Double(courseImageView.frame.width / scale)
        height = height * percentageDifference / Double(scale)

        let imageOptions: [ImageOption] = [.formatAs(.jpg(withQuality: .asPercent(100)))]

        do {
            let url = try asset.url(with: imageOptions)

            // Use AlamofireImage extensons to fetch the image and render the image veiw.
            courseImageView.af_setImage(withURL: url,
                                        placeholderImage: nil,
                                        imageTransition: .crossDissolve(0.5),
                                        runImageTransitionIfCached: true)

        } catch  {
            // TODO:
        }

    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = .white
            let font = UIFont(name: "SFProText-Bold", size: 28.0)
            titleLabel.font = font
        }
    }

    @IBOutlet weak var descriptionLabel: UILabel! { didSet {} }

    @IBOutlet weak var imageOverlayView: UIView! {
        didSet {
            imageOverlayView.backgroundColor = UIColor(red: 0.24, green: 0.24, blue: 0.25, alpha: 0.8)
            imageOverlayView.layer.cornerRadius = 15.0
        }
    }

    @IBOutlet weak var courseImageView: UIImageView! {
        didSet {
            courseImageView.layer.cornerRadius = 15.0
        }
    }
}
