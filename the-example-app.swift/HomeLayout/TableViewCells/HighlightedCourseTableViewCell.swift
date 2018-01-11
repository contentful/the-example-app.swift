
import Foundation
import UIKit
import AlamofireImage
import Contentful

class HighlightedCourseTableViewCell: UITableViewCell, CellConfigurable {

    struct Model {
        let highlightedCourse: HighlightedCourse
        let didTapViewCourseButton: (() -> Void)?
    }

    var viewModel: Model?

    func configure(item: Model) {
        viewModel = item

        if let title = viewModel?.highlightedCourse.course?.title {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1.14
            let attributedText = NSAttributedString(string: title, attributes: [.paragraphStyle: paragraphStyle])
            titleLabel.attributedText = attributedText
        }

        if let description = viewModel?.highlightedCourse.course?.courseDescription {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1.27
            let attributedText = NSAttributedString(string: description, attributes: [.paragraphStyle: paragraphStyle])
            descriptionLabel.attributedText = attributedText
        }

        if let category = viewModel?.highlightedCourse.course?.categories?.first {
            categoryLabel.text = category.title.uppercased()
        }

        guard let asset = item.highlightedCourse.course?.imageAsset else {
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


    override func layoutSubviews() {
        super.layoutSubviews()
        viewCourseButton.layer.cornerRadius = viewCourseButton.frame.height / 2.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBAction func viewCourseButtonAction(_ sender: Any) {
        viewModel?.didTapViewCourseButton?()
    }

    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.masksToBounds = false
            containerView.layer.cornerRadius = 15.0
            containerView.layer.shadowRadius = 6.0
            containerView.layer.shadowOpacity = 0.8
            containerView.layer.shadowColor = UIColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 1).cgColor
            containerView.layer.shadowOffset = CGSize(width: 7.0, height: 7.0)
        }
    }

    @IBOutlet weak var viewCourseButton: UIButton! {
        didSet {
            viewCourseButton.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
            viewCourseButton.layer.cornerRadius = 20.0
            viewCourseButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            viewCourseButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), for: .normal)
        }
    }

    @IBOutlet weak var categoryLabel: UILabel! {
        didSet {
            categoryLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
            categoryLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .bold)
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
