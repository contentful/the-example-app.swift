
import Foundation
import Contentful

class LayoutModule: Module {}

class LayoutHighlightedCourse: LayoutModule, ResourceQueryable, EntryModellable {

    static let contentTypeId = "layoutHighlightedCourse"

    let title: String

    var course: Course?

    required init(from decoder: Decoder) throws {
        let container   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        title           = try container.decode(String.self, forKey: .title)

        try super.init(sys: decoder.sys())

        try container.resolveLink(forKey: .course, decoder: decoder) { [weak self] course in
            self?.course = course as? Course
        }
    }

    enum Fields: String, CodingKey {
        case title, course
    }
}

class LayoutHeroImage: LayoutModule, ResourceQueryable, EntryModellable {

    static let contentTypeId = "layoutHeroImage"

    let title: String
    let headline: String

    var backgroundImage: Asset?

    required init(from decoder: Decoder) throws {
        let container   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        title           = try! container.decode(String.self, forKey: .title)
        headline        = try! container.decode(String.self, forKey: .headline)

        try super.init(sys: decoder.sys())

        try! container.resolveLink(forKey: .backgroundImage, decoder: decoder) { [weak self] asset in
            self?.backgroundImage = asset as? Asset
        }
    }

    enum Fields: String, CodingKey {
        case title, headline, backgroundImage
    }
}

class LayoutCopy: LayoutModule, ResourceQueryable, EntryModellable {

    static let contentTypeId = "layoutCopy"

    let copy: String
    let headline: String?
    let ctaTitle: String?
    let ctaLink: String?
    let visualStyle: Style?


    required init(from decoder: Decoder) throws {

        let container   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        copy            = try! container.decode(String.self, forKey: .copy)
        headline        = try! container.decodeIfPresent(String.self, forKey: .headline)
        ctaTitle        = try! container.decodeIfPresent(String.self, forKey: .ctaTitle)
        ctaLink         = try! container.decodeIfPresent(String.self, forKey: .ctaLink)
        visualStyle     = try! container.decodeIfPresent(Style.self, forKey: .visualStyle)

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
