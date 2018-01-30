
import Foundation
import UIKit

class CourseTableViewCell: UITableViewCell, CellConfigurable {

    struct Model {
        let contentfulService: ContentfulService
        let course: Course
        let backgroundColor: UIColor
        let didTapViewCourseButton: (() -> Void)?
    }

    var viewModel: Model?

    func configure(item: Model) {
        viewModel = item

        if let firstCategory = item.course.categories?.first {
            categoryLabel.text = firstCategory.title
        }

        containerView.backgroundColor = viewModel?.backgroundColor
        titleLabel.text = item.course.title
        shortDescriptionLabel.text = item.course.shortDescription

        accessibilityLabel = item.course.title

        if item.contentfulService.shouldShowResourceStateLabels {
            switch item.course.state {
            case .upToDate:
                trailingStateTextView.isHidden = true
                leadingStateTextView.isHidden = true

            case .draft:

                trailingStateTextView.isHidden = true
                leadingStateTextView.isHidden = false
                leadingStateTextView.showDraftState()
                setNeedsLayout()

            case .draftAndPendingChanges:
                trailingStateTextView.isHidden = false
                leadingStateTextView.isHidden = false

                leadingStateTextView.showDraftState()
                trailingStateTextView.showPendingChangesState()
                setNeedsLayout()

            case .pendingChanges:
                trailingStateTextView.isHidden = true
                leadingStateTextView.isHidden = false

                leadingStateTextView.showPendingChangesState()
                setNeedsLayout()
            }
        }
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        viewCourseButton.layer.cornerRadius = viewCourseButton.frame.height / 2.0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        selectionStyle = .none
    }

    @IBOutlet weak var leadingStateTextView: UITextView! {
        didSet {
            leadingStateTextView.textContainerInset = UITextView.resourceStateInsets
            leadingStateTextView.font = UIFont.systemFont(ofSize: 11.0, weight: .regular)
            leadingStateTextView.textColor = .white
            leadingStateTextView.layer.cornerRadius = 3
            leadingStateTextView.layer.masksToBounds = true
            leadingStateTextView.isHidden = true
        }
    }

    @IBOutlet weak var trailingStateTextView: UITextView! {
        didSet {
            trailingStateTextView.textContainerInset = UITextView.resourceStateInsets
            trailingStateTextView.font = UIFont.systemFont(ofSize: 11.0, weight: .regular)
            trailingStateTextView.textColor = .white
            trailingStateTextView.layer.cornerRadius = 3
            trailingStateTextView.layer.masksToBounds = true
            trailingStateTextView.isHidden = true
        }
    }

    @IBAction func viewCourseButtonAction(_ sender: Any) {
        viewModel?.didTapViewCourseButton?()
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

    @IBOutlet weak var shortDescriptionLabel: UILabel! {
        didSet {
            shortDescriptionLabel.textColor = .white
            shortDescriptionLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .regular)
        }
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
}
