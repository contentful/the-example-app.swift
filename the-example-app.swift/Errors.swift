
import Foundation
import UIKit

protocol ApplicationError: Error {
    var headline: String { get }
    var message: NSAttributedString { get }
}


func attributedErrorMessageHeader(errorMessageKey: String,
                        hintsKeys: [String],
                        fontSize: CGFloat, contentfulService: ContentfulService) -> NSMutableAttributedString {
    let regularAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: fontSize, weight: .regular)]
    let string = NSMutableAttributedString(string: errorMessageKey.localized(contentfulService: contentfulService),
                                           attributes: regularAttributes)

    string.append(NSAttributedString(string: "\n" + "hintsLabel".localized(contentfulService: contentfulService) + "\n",
                                     attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: .bold)]))
    for key in hintsKeys {
        let hintString = NSAttributedString(string: "\n• \(key.localized(contentfulService: contentfulService))", attributes: regularAttributes)
        string.append(hintString)
    }
    return string
}

struct NoContentError: ApplicationError {
    
    let headline: String
    let message: NSAttributedString
    let route: String

    static func noCategories(contentfulService: ContentfulService, route: String, fontSize: CGFloat) -> NoContentError {
        let message = attributedErrorMessageHeader(errorMessageKey: "errorMessage404Category",
                                                   hintsKeys: ["notFoundErrorHint", "draftOrPublishedErrorHint"],
                                                   fontSize: fontSize,
                                                   contentfulService: contentfulService)
        let headline = """
        \("somethingWentWrongLabel".localized(contentfulService: contentfulService))
        No content for '\(route)'
        """
        return NoContentError(headline: headline, message: message, route: route)
    }

    static func noCourses(contentfulService: ContentfulService, route: String, fontSize: CGFloat) -> NoContentError {

        let message = attributedErrorMessageHeader(errorMessageKey: "errorMessage404Course",
                                                   hintsKeys: ["notFoundErrorHint", "draftOrPublishedErrorHint"],
                                                   fontSize: fontSize,
                                                   contentfulService: contentfulService)
        let headline = """
        \("somethingWentWrongLabel".localized(contentfulService: contentfulService))
        Invalid route '\(route)'
        """
        return NoContentError(headline: headline, message: message, route: route)
    }

    static func noHomeLayout(contentfulService: ContentfulService, route: String, fontSize: CGFloat) -> NoContentError {

        let message = attributedErrorMessageHeader(errorMessageKey: "errorMessage404Route",
                                                   hintsKeys: ["notFoundErrorHint", "draftOrPublishedErrorHint"],
                                                   fontSize: fontSize,
                                                   contentfulService: contentfulService)
        let headline = """
        \("somethingWentWrongLabel".localized(contentfulService: contentfulService))
        """

        return NoContentError(headline: headline, message: message, route: route)
    }

    static func noLessons(contentfulService: ContentfulService, route: String, fontSize: CGFloat) -> NoContentError {
        let message = attributedErrorMessageHeader(errorMessageKey: "errorMessage404Lesson",
                                                   hintsKeys: ["notFoundErrorHint", "draftOrPublishedErrorHint"],
                                                   fontSize: fontSize,
                                                   contentfulService: contentfulService)
        
        let headline = """
        \("somethingWentWrongLabel".localized(contentfulService: contentfulService))
        Invalid route '\(route)'
        """
        return NoContentError(headline: headline, message: message, route: route)
    }

    static func invalidRoute(contentfulService: ContentfulService, route: String, fontSize: CGFloat) -> NoContentError {

        let message = attributedErrorMessageHeader(errorMessageKey: "errorMessage404Route",
                                                   hintsKeys: ["notFoundErrorHint", "draftOrPublishedErrorHint"],
                                                   fontSize: fontSize,
                                                   contentfulService: contentfulService)
        let headline = """
        \("somethingWentWrongLabel".localized(contentfulService: contentfulService))
        Invalid route '\(route)'
        """

        return NoContentError(headline: headline, message: message, route: route)
    }
}

struct RenderingError: ApplicationError {

    let headline: String
    let message: NSAttributedString

}

