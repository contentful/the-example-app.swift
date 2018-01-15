
import Foundation
import UIKit


class ConnectedSpaceViewController: UITableViewController {

    var services: Services!

    static func new(services: Services) -> ConnectedSpaceViewController {
        let viewController = UIStoryboard.init(name: String(describing: ConnectedSpaceViewController.self), bundle: nil).instantiateInitialViewController() as! ConnectedSpaceViewController
        viewController.services = services
        return viewController
    }

    @IBOutlet weak var currentlyConnectedSpaceLabel: UILabel!

    override func loadView() {
        super.loadView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha:1.0)
        if services.contentful.spaceId != ContentfulCredentials.default.spaceId
            && services.contentful.deliveryAccessToken != ContentfulCredentials.default.deliveryAPIAccessToken
            && services.contentful.previewAccessToken != ContentfulCredentials.default.previewAPIAccessToken {
            resetCredentialsButton.isEnabled = true
        } else {
            resetCredentialsButton.isEnabled = false
        }
    }

    @IBOutlet weak var resetCredentialsButton: UIButton!

    @IBAction func resetCredentialsButtonAction(_ sender: Any) {
        services.contentful = ContentfulService(session: services.session,
                                                credentials: ContentfulCredentials.default,
                                                api: services.contentful.apiStateMachine.state,
                                                editorialFeaturesEnabled: services.contentful.editorialFeaturesStateMachine.state)
    }
}
