
import Foundation
import Contentful

class LayoutModule: Module {}

class LayoutHighlightedCourse: LayoutModule, EntryQueryable, EntryModellable {

    static let contentTypeId = "layoutHighlightedCourse"

    let title: String

    var course: Course?

    required init(from decoder: Decoder) throws {
        let fields  = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        title       = try fields.decode(String.self, forKey: .title)

        try super.init(sys: decoder.sys())

        try fields.resolveLink(forKey: .course, decoder: decoder) { [weak self] course in
            self?.course = course as? Course
        }
    }

    enum Fields: String, CodingKey {
        case title, course
    }
}

class LayoutHeroImage: LayoutModule, EntryQueryable, EntryModellable {

    static let contentTypeId = "layoutHeroImage"

    let title: String
    let headline: String

    var backgroundImage: Asset?

    required init(from decoder: Decoder) throws {
        let fields  = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        title       = try fields.decode(String.self, forKey: .title)
        headline    = try fields.decode(String.self, forKey: .headline)

        try super.init(sys: decoder.sys())

        try fields.resolveLink(forKey: .backgroundImage, decoder: decoder) { [weak self] asset in
            self?.backgroundImage = asset as? Asset
        }
    }

    enum Fields: String, CodingKey {
        case title, headline, backgroundImage
    }
}

class LayoutCopy: LayoutModule, EntryQueryable, EntryModellable {

    static let contentTypeId = "layoutCopy"

    let copy: String
    let headline: String?
    let ctaTitle: String?
    let ctaLink: String?
    let visualStyle: Style?


    required init(from decoder: Decoder) throws {

        let fields  = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        copy        = try fields.decode(String.self, forKey: .copy)
        headline    = try fields.decodeIfPresent(String.self, forKey: .headline)
        ctaTitle    = try fields.decodeIfPresent(String.self, forKey: .ctaTitle)
        ctaLink     = try fields.decodeIfPresent(String.self, forKey: .ctaLink)
        visualStyle = try fields.decodeIfPresent(Style.self, forKey: .visualStyle)

        try super.init(sys: decoder.sys())
    }

    enum Fields: String, CodingKey {
        case copy, headline, ctaTitle, ctaLink, visualStyle
    }

    enum Style: String, Decodable {
        case emphasized = "Emphasized"
        case `default`  = "Default"
    }
}
