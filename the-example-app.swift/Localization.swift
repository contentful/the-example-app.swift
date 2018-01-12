
import Foundation
import UIKit

// https://stackoverflow.com/a/31744226/4068264
extension String {

    func localized() -> String {
        let language = (UIApplication.shared.delegate as! AppDelegate).services.contentful.localeStateMachine.state.code()
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
