
import Foundation
import Contentful

class LessonModule: Module {}

class LessonCopy: LessonModule, EntryQueryable, EntryModellable {

    static let contentTypeId = "lessonCopy"

    let copy: String

    required init(from decoder: Decoder) throws {
        let fields  = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        copy        = try fields.decode(String.self, forKey: .copy)

        try super.init(sys: decoder.sys())
    }

    enum Fields: String, CodingKey {
        case copy
    }
}

class LessonImage: LessonModule, EntryQueryable, EntryModellable {

    static let contentTypeId = "lessonImage"

    let caption: String?

    // Links must be declared optional.
    var image: Asset?

    required init(from decoder: Decoder) throws {
        let fields  = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        caption     = try fields.decodeIfPresent(String.self, forKey: .caption)

        try super.init(sys: decoder.sys())

        // Resolve link.
        try fields.resolveLink(forKey: .image, decoder: decoder) { [weak self] image in
            self?.image = image as? Asset
        }
    }

    enum Fields: String, CodingKey {
        case image, caption
    }
}

class LessonSnippets: LessonModule, EntryQueryable, EntryModellable {

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
        let fields  = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        swift       = try fields.decode(String.self, forKey: .swift)
        java        = try fields.decode(String.self, forKey: .java)
        dotNet      = try fields.decode(String.self, forKey: .dotNet)
        curl        = try fields.decode(String.self, forKey: .curl)
        python      = try fields.decode(String.self, forKey: .python)
        ruby        = try fields.decode(String.self, forKey: .ruby)
        php         = try fields.decode(String.self, forKey: .php)
        javaAndroid = try fields.decode(String.self, forKey: .javaAndroid)
        javascript  = try fields.decode(String.self, forKey: .javascript)
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
            case .swift:        return "Swift"
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
