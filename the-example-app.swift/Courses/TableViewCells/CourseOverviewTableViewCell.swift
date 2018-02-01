
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

        accessibilityLabel = "Course overview: \(item.course.title)"

        if let description = item.course.courseDescription {
            courseDescriptionTextView.attributedText = Markdown.attributedMarkdownText(text: description, font: UIFont.systemFont(ofSize: 16.0, weight: .light))
            courseDescriptionTextView.sizeToFit()
        }

        if let duration = item.course.duration, let skillLevel = item.course.skillLevel {
            detailsLabel.text = "\("durationLabel".localized(contentfulService: item.contentfulService)): \(duration) \("minutesLabel".localized(contentfulService: item.contentfulService)) • \("skillLevelLabel".localized(contentfulService: item.contentfulService)): \(skillLevel)"
        }
        startCourseButton.setTitle("startCourseLabel".localized(contentfulService: item.contentfulService), for: .normal)

        if item.contentfulService.shouldShowResourceStateLabels {
            switch item.course.state {
            case .upToDate:
                entryStatesContainerView.isHidden = true
                entryStatesViewHeightConstraint.constant = 0.0

                stackView.setCustomSpacing(0.0, after: entryStatesContainerView)

            case .draft:
                entryStatesContainerView.isHidden = false
                trailingStateTextView.isHidden = true
                leadingStateTextView.isHidden = false
                entryStatesViewHeightConstraint.constant = 16.0
                stackView.setCustomSpacing(4.0, after: entryStatesContainerView)

                leadingStateTextView.showDraftState()

            case .draftAndPendingChanges:
                entryStatesContainerView.isHidden = false
                trailingStateTextView.isHidden = false
                leadingStateTextView.isHidden = false
                entryStatesViewHeightConstraint.constant = 16.0
                stackView.setCustomSpacing(4.0, after: entryStatesContainerView)

                leadingStateTextView.showDraftState()
                trailingStateTextView.showPendingChangesState()

            case .pendingChanges:
                entryStatesContainerView.isHidden = false
                trailingStateTextView.isHidden = true
                leadingStateTextView.isHidden = false
                entryStatesViewHeightConstraint.constant = 16.0

                stackView.setCustomSpacing(4.0, after: entryStatesContainerView)
                leadingStateTextView.showPendingChangesState()
            }
        } else {
            entryStatesViewHeightConstraint.constant = 0.0
            stackView.setCustomSpacing(0.0, after: entryStatesContainerView)
        }
    }

    func resetAllContent() {
        viewModel = nil
        accessibilityLabel = nil

        courseDescriptionTextView.text = ""
        detailsLabel.text = nil

        stackView.setCustomSpacing(0.0, after: entryStatesContainerView)
        entryStatesContainerView.isHidden = true
        entryStatesViewHeightConstraint.constant = 0.0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        startCourseButton.layer.cornerRadius = startCourseButton.frame.height / 2.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        stackView.setCustomSpacing(4.0, after: entryStatesContainerView)
        stackView.setCustomSpacing(8.0, after: detailsLabel)
    }

    @IBOutlet weak var entryStatesContainerView: UIView!
    @IBOutlet weak var entryStatesViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var courseTitleLabel: UILabel! {
        didSet {
            courseTitleLabel.textColor = .black
            courseTitleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
        }
    }

    @IBOutlet weak var leadingStateTextView: UITextView! {
        didSet {
            leadingStateTextView.textContainerInset = UITextView.resourceStateInsets
            leadingStateTextView.textContainer.maximumNumberOfLines = 1
            leadingStateTextView.font = UIFont.systemFont(ofSize: 11.0, weight: .regular)
            leadingStateTextView.textColor = .white
            leadingStateTextView.layer.cornerRadius = 3
            leadingStateTextView.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var trailingStateTextView: UITextView! {
        didSet {
            trailingStateTextView.textContainerInset = UITextView.resourceStateInsets
            trailingStateTextView.textContainer.maximumNumberOfLines = 1
            trailingStateTextView.font = UIFont.systemFont(ofSize: 11.0, weight: .regular)
            trailingStateTextView.textColor = .white
            trailingStateTextView.layer.cornerRadius = 3
            trailingStateTextView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var detailsLabel: UILabel! {
        didSet {
            detailsLabel.textColor = .gray
            detailsLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .light)
        }
    }

    @IBOutlet weak var courseDescriptionTextView: UITextView!

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
