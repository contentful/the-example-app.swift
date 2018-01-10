
import Foundation
import UIKit

extension UIAlertController {

    static func invalidSpaceIdErrorController() -> UIAlertController {
        let title = "Error occurred"
        let message = "This space does not exist or your access token is not associated with your space."
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default) { alertAction in
            controller.dismiss(animated: true, completion: nil)
        })
        return controller
    }
}
