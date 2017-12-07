
import Foundation
import UIKit

class SettingsViewController: UIViewController {

    let contentful: Contentful

    init(services: Services) {
        self.contentful = services.contentful
        super.init(nibName: "SettingsView", bundle: nil)
        self.title = NSLocalizedString("Settings", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        editorialFeaturesSwitch.isOn = contentful.editorialFeaturesAreEnabled
    }

    @IBOutlet weak var editorialFeaturesSwitch: UISwitch!

    @IBAction func didToggleEditorialFeatures(_ sender: Any) {
        contentful.enableEditorialFeatures(editorialFeaturesSwitch.isOn)
    }
}
