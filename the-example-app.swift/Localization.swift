
import Foundation
import UIKit
import Contentful

// https://stackoverflow.com/a/31744226/4068264
extension String {

    func localized(contentfulService: ContentfulService) -> String {
        let localeCode = contentfulService.stateMachine.state.locale.code()

        let path = Bundle.main.path(forResource: localeCode, ofType: "lproj")
        let bundle = Bundle(path: path!)
        let string = NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")

        return string
    }
}
