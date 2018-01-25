
import Foundation
import UIKit

class ResourceStatesTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = ResourceState

    func configure(item: ResourceState) {
        switch item {
        case .upToDate:
            hide(true)
        case .draft:
            showLeadingAndHideTrailing()
            leadingTextView.showDraftState()

        case .pendingChanges:
            showLeadingAndHideTrailing()
            leadingTextView.showPendingChangesState()

        case .draftAndPendingChanges:
            hide(false)
            leadingTextView.showDraftState()
            trailingTextView.showPendingChangesState()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    @IBOutlet weak var leadingTextView: UITextView! {
        didSet {
            leadingTextView.textContainerInset = UITextView.resourceStateInsets
            leadingTextView.layer.cornerRadius = 4.0
            leadingTextView.layer.masksToBounds = true
            leadingTextView.textColor = .white
            leadingTextView.font = UIFont.systemFont(ofSize: 11.0, weight: .regular)
        }
    }

    @IBOutlet weak var trailingTextView: UITextView! {
        didSet {
            trailingTextView.textContainerInset = UITextView.resourceStateInsets
            trailingTextView.layer.cornerRadius = 4.0
            trailingTextView.layer.masksToBounds = true
            trailingTextView.textColor = .white
            trailingTextView.font = UIFont.systemFont(ofSize: 11.0, weight: .regular)
        }
    }

    func hide(_ hide: Bool) {
        leadingTextView.isHidden = hide
        trailingTextView.isHidden = hide
    }

    func showLeadingAndHideTrailing() {
        leadingTextView.isHidden = false
        trailingTextView.isHidden = true
    }
}
