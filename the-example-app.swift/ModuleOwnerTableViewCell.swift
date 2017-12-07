
import Foundation
import UIKit

class ModuleOwnerStateTableViewCell: UITableViewCell, CellConfigurable {

    typealias ItemType = ResourceState

    func configure(item: ResourceState) {
        switch item {
        case .upToDate:
            backgroundColor = .blue
        case .draft:
            backgroundColor = .purple
        case .pendingChanges:
            backgroundColor = .yellow
        }
    }
}
