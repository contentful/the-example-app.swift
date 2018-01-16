
import Foundation
import UIKit

class CourseOverviewTableViewCell: UITableViewCell, CellConfigurable {

    struct Model {
        let contentfulService: ContentfulService
        let course: Course
        let didTapStartCourseButton: (() -> Void)?
    }

    var viewModel: Model?

    func configure(item: Model) {
        viewModel = item
        courseTitleLabel.text = item.course.title

        if let description = item.course.courseDescription {
            courseDescriptionLabel.attributedText = Markdown.attributedMarkdownText(text: description, font: UIFont.systemFont(ofSize: 17.0, weight: .regular))
        }

        if let duration = item.course.duration, let skillLevel = item.course.skillLevel {
            detailsLabel.text = "\("durationLabel".localized(contentfulService: item.contentfulService)): \(duration) \("minutesLabel".localized(contentfulService: item.contentfulService)) • \("skillLevelLabel".localized(contentfulService: item.contentfulService)): \(skillLevel)"
        }
        startCourseButton.setTitle("startCourseLabel".localized(contentfulService: item.contentfulService), for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        startCourseButton.layer.cornerRadius = startCourseButton.frame.height / 2.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    @IBOutlet weak var courseTitleLabel: UILabel! {
        didSet {
            courseTitleLabel.textColor = .black
            courseTitleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
        }
    }

    @IBOutlet weak var detailsLabel: UILabel! {
        didSet {
            detailsLabel.textColor = .gray
            detailsLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        }
    }

    @IBOutlet weak var courseDescriptionLabel: UILabel!

    @IBOutlet weak var startCourseButton: UIButton! {
        didSet {
            startCourseButton.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
            startCourseButton.layer.cornerRadius = 20.0
            startCourseButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            startCourseButton.setTitleColor(.white, for: .normal)
        }
    }

    @IBAction func startCourseButtonAction(_ sender: Any) {
        viewModel?.didTapStartCourseButton?()
    }
}
