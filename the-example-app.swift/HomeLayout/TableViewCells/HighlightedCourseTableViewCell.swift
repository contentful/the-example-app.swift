
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
        guard let width = asset.file?.details?.imageInfo?.width else { return }
        guard let height = asset.file?.details?.imageInfo?.height else { return }

        // Use scale to get the pixel size of the image view.
        let scale = UIScreen.main.scale
        let viewWidthInPx = Double(courseImageView.frame.width * scale)
        let percentageDifference = viewWidthInPx / width

        let viewHeightInPoints = height * percentageDifference / Double(scale)
        let viewHeightInPx = viewHeightInPoints * Double(scale)

        let imageOptions: [ImageOption] = [
            .formatAs(.jpg(withQuality: .asPercent(100))),
            .width(UInt(viewWidthInPx)),
            .height(UInt(viewHeightInPx)),
            .fit(for: Fit.crop(focusingOn: nil))
        ]

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
            titleLabel.font = UIFont.systemFont(ofSize: 28.0, weight: .bold)
        }
    }

    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.textColor = .white
            descriptionLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        }
    }

    @IBOutlet weak var imageOverlayView: UIView! {
        didSet {
            imageOverlayView.backgroundColor = UIColor(red: 0.24, green: 0.24, blue: 0.25, alpha: 0.8)
            imageOverlayView.layer.cornerRadius = 15.0
            imageOverlayView.clipsToBounds = true
        }
    }

    @IBOutlet weak var courseImageView: UIImageView! {
        didSet {
            courseImageView.layer.cornerRadius = 15.0
            courseImageView.contentMode = .center
            courseImageView.clipsToBounds = true
        }
    }
}
