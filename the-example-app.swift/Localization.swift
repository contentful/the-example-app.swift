
import Foundation
import UIKit
import Contentful

// https://stackoverflow.com/a/31744226/4068264
extension String {

    func localized(contentfulService: ContentfulService) -> String {
        let locale = contentfulService.stateMachine.state.locale
        let path: String

        if let availablePath = Bundle.main.path(forResource: locale.code, ofType: "lproj") {
            path = availablePath
        } else if let fallbackLocale = contentfulService.firstSupportedFallbackLocale(start: locale), let availablePath = Bundle.main.path(forResource: fallbackLocale.code, ofType: "lproj") {
            path = availablePath
        } else {
            // Default to American English if we can't find anything for the locale.
            path = Bundle.main.path(forResource: Contentful.Locale.americanEnglish().code, ofType: "lproj")!
        }

        let bundle = Bundle(path: path)
        let string = NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")

        return string
    }
}


extension ContentfulService {

    fileprivate func firstSupportedFallbackLocale(start locale: Contentful.Locale) -> Contentful.Locale? {
        guard let fallbackLocaleCode = locale.fallbackLocaleCode else { return nil }
        guard let fallbackLocale = self.locales.filter({ $0.code == fallbackLocaleCode }).first else { return nil }

        // Check if the locale has a localization file in the app's buncle.
        if Bundle.main.path(forResource: fallbackLocale.code, ofType: "lproj") == nil {
            // Recurse.
            return firstSupportedFallbackLocale(start: fallbackLocale)
        }
        return fallbackLocale
    }
}
