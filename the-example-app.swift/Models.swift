
import Foundation
import Contentful

class Module: Resource, StatefulResource {

    let sys: Sys

    init(sys: Sys) {
        self.sys = sys
    }
    
    var state = ResourceState.upToDate
}

class LayoutModule: Module {}
class LessonModule: Module {}

class HomeLayout: NSObject, EntryDecodable, ResourceQueryable, StatefulResource {

    static let contentTypeId = "layout"
    
    let sys: Sys
    let slug: String
    var modules: [LayoutModule]?

    var state = ResourceState.upToDate

    required init(from decoder: Decoder) throws {
        sys             = try! decoder.sys()
        let container   = try! decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        slug            = try! container.decode(String.self, forKey: .slug)

        super.init()

        try! container.resolveLinksArray(forKey: .modules, decoder: decoder) { [weak self] array in
            self?.modules = array as? [LayoutModule]
        }
    }

    enum Fields: String, CodingKey {
        case slug
        case modules = "contentModules"
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

class HighlightedCourse: LayoutModule, ResourceQueryable, EntryModellable {

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

class Lesson: NSObject, EntryDecodable, ResourceQueryable, StatefulResource {

    static let contentTypeId = "lesson"

    let sys: Sys
    let title: String
    let slug: String
    var modules: [LessonModule]?

    var state = ResourceState.upToDate

    required init(from decoder: Decoder) throws {

        sys             = try decoder.sys()
        let container   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        title           = try container.decode(String.self, forKey: .title)
        slug            = try container.decode(String.self, forKey: .slug)
        super.init()

        try container.resolveLinksArray(forKey: .modules, decoder: decoder) { [weak self] array in
            self?.modules = array as? [LessonModule]
        }
    }

    enum Fields: String, CodingKey {
        case title, slug, modules
    }
}

class Course: EntryDecodable, ResourceQueryable, StatefulResource {

    static let contentTypeId = "course"

    let sys: Sys

    let title: String
    let slug: String
    let shortDescription: String?
    let courseDescription: String?
    let duration: Int?
    let skillLevel: String?

    var imageAsset: Asset?
    var lessons: [Lesson]?
    var categories: [Category]?

    var state = ResourceState.upToDate

    required init(from decoder: Decoder) throws {
        sys                 = try! decoder.sys()
        let container       = try! decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        title               = try! container.decode(String.self, forKey: .title)
        slug                = try! container.decode(String.self, forKey: .slug)
        shortDescription    = try! container.decodeIfPresent(String.self, forKey: .shortDescription)
        courseDescription   = try! container.decodeIfPresent(String.self, forKey: .courseDescription)
        duration            = try! container.decodeIfPresent(Int.self, forKey: .duration)
        skillLevel          = try! container.decodeIfPresent(String.self, forKey: .skillLevel)

        try! container.resolveLink(forKey: .imageAsset, decoder: decoder) { [weak self] asset in
            self?.imageAsset = asset as? Asset
        }
        try! container.resolveLinksArray(forKey: .lessons, decoder: decoder) { [weak self] array in
            self?.lessons = array as? [Lesson]
        }
        try! container.resolveLinksArray(forKey: .categories, decoder: decoder) { [weak self] array in
            self?.categories = array as? [Category]
        }
    }

    enum Fields: String, CodingKey {
        case title, slug, shortDescription, duration, skillLevel, lessons, categories
        case imageAsset = "image"
        case courseDescription = "description"
    }

}

extension Category: Equatable {
    static func ==(lhs: Category, rhs: Category) -> Bool {
        return rhs.id == lhs.id && rhs.localeCode == lhs.localeCode
    }
}

class Category: EntryDecodable, ResourceQueryable, StatefulResource {
    
    static let contentTypeId = "category"

    let sys: Sys
    let slug: String
    let title: String

    var state = ResourceState.upToDate

    required init(from decoder: Decoder) throws {
        sys             = try decoder.sys()
        let container   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        title           = try container.decode(String.self, forKey: .title)
        slug            = try container.decode(String.self, forKey: .slug)
    }

    enum Fields: String, CodingKey {
        case slug, title
    }
}

class LessonCopy: LessonModule, ResourceQueryable, EntryModellable {

    static let contentTypeId = "lessonCopy"
    
    let copy: String


    required init(from decoder: Decoder) throws {
        let container   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        copy            = try container.decode(String.self, forKey: .copy)
        try super.init(sys: decoder.sys())
    }

    enum Fields: String, CodingKey {
        case copy
    }
}

class LessonImage: LessonModule, ResourceQueryable, EntryModellable {

    static let contentTypeId = "lessonImage"

    // Links must be declared optional.
    var image: Asset?


    required init(from decoder: Decoder) throws {
        let container   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)

        try super.init(sys: decoder.sys())

        // Resolve link.
        try container.resolveLink(forKey: .image, decoder: decoder) { [weak self] image in
            self?.image = image as? Asset
        }
    }

    enum Fields: String, CodingKey {
        case image
    }
}

class LessonSnippets: LessonModule, ResourceQueryable, EntryModellable {

    static let contentTypeId = "lessonCodeSnippets"

    static let numberSupportedLanguages = 9

    let swift: String
    let java: String
    let dotNet: String
    let curl: String
    let python: String
    let ruby: String
    let javascript: String
    let php: String
    let javaAndroid: String


    required init(from decoder: Decoder) throws {
        let container   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        swift           = try container.decode(String.self, forKey: .swift)
        java            = try container.decode(String.self, forKey: .java)
        dotNet          = try container.decode(String.self, forKey: .dotNet)
        curl            = try container.decode(String.self, forKey: .curl)
        python          = try container.decode(String.self, forKey: .python)
        ruby            = try container.decode(String.self, forKey: .ruby)
        php             = try container.decode(String.self, forKey: .php)
        javaAndroid     = try container.decode(String.self, forKey: .javaAndroid)
        javascript      = try container.decode(String.self, forKey: .javascript)
        try super.init(sys: decoder.sys())
    }

    func valueForField(_ field: Fields) -> String {
        switch field {
        case .swift:            return swift
        case .java:             return java
        case .javaAndroid:      return javaAndroid
        case .curl:             return curl
        case .dotNet:           return dotNet
        case .javascript:       return javascript
        case .php:              return php
        case .ruby:             return ruby
        case .python:           return python
        }
    }
    enum Fields: String, CodingKey {
        case swift, javascript, dotNet, curl, java, javaAndroid, php, python, ruby

        func displayName() -> String {
            switch self {
            case .swift:    	return "Swift"
            case .java:         return "Java"
            case .javaAndroid:  return "Android"
            case .curl:         return "cURL"
            case .dotNet:       return ".NET"
            case .javascript:   return "JavaScript"
            case .php:          return "PHP"
            case .ruby:         return "Ruby"
            case .python:       return "Python"
            }
        }
    }
}
