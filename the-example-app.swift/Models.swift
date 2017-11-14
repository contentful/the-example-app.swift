//
//  Models.swift
//  TestMarkdown
//
//  Created by JP Wright on 02.11.17.
//  Copyright © 2017 Contentful. All rights reserved.
//


import Foundation
import Contentful

class Lesson: EntryDecodable, ResourceQueryable {

    static let contentTypeId = "lesson"

    let sys: Sys
    let slug: String
    var modules: [LessonModule]?

    required init(from decoder: Decoder) throws {
        sys             = try! decoder.sys()
        let container   = try! decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        slug            = try! container.decode(String.self, forKey: .slug)
        try container.resolveLinksArray(forKey: .modules, decoder: decoder) { [weak self] array in
            self?.modules = array as? [LessonModule]
        }
    }

    enum Fields: String, CodingKey {
        case slug, modules
    }
}

protocol LessonModule: EntryDecodable {}

protocol RenderableLessonModule {
    var viewType: UITableViewCell.Type { get }
}

class LessonCopy: LessonModule, ResourceQueryable, RenderableLessonModule {

    let viewType: UITableViewCell.Type = LessonCopyTableViewCell.self

    static let contentTypeId = "lessonCopy"
    
    let sys: Sys
    let copy: String

    required init(from decoder: Decoder) throws {
        sys             = try decoder.sys()
        let container   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        copy            = try container.decode(String.self, forKey: .copy)
    }

    enum Fields: String, CodingKey {
        case copy
    }
}

class LessonImage: LessonModule, ResourceQueryable, RenderableLessonModule {

    let viewType: UITableViewCell.Type = LessonCopyTableViewCell.self

    static let contentTypeId = "lessonImage"

    let sys: Sys

    // Links must be declared optional.
    var image: Asset?

    required init(from decoder: Decoder) throws {
        sys             = try decoder.sys()
        let container   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)

        // Resolve link.
        try container.resolveLink(forKey: .image, decoder: decoder) { [weak self] image in
            self?.image = image as? Asset
        }
    }

    enum Fields: String, CodingKey {
        case image
    }
}

class LessonSnippets: LessonModule, ResourceQueryable, RenderableLessonModule {

    let viewType: UITableViewCell.Type = LessonSnippetsTableViewCell.self

    static let contentTypeId = "lessonSnippets"

    let sys: Sys
    let swift: String

    required init(from decoder: Decoder) throws {
        sys             = try decoder.sys()
        let container   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        swift           = try container.decode(String.self, forKey: .swift)
    }

    enum Fields: String, CodingKey {
        case swift
    }
}
