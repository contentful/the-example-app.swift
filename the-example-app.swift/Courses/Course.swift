
import Foundation
import Contentful

class Course: EntryDecodable, EntryQueryable, StatefulResource {

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

    var hasLessons: Bool {
        return lessons != nil && lessons!.count > 0
    }
    var categories: [Category]?

    var state = ResourceState.upToDate

    required init(from decoder: Decoder) throws {
        sys                 = try decoder.sys()
        let fields          = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        title               = try fields.decode(String.self, forKey: .title)
        slug                = try fields.decode(String.self, forKey: .slug)
        shortDescription    = try fields.decodeIfPresent(String.self, forKey: .shortDescription)
        courseDescription   = try fields.decodeIfPresent(String.self, forKey: .courseDescription)
        duration            = try fields.decodeIfPresent(Int.self, forKey: .duration)
        skillLevel          = try fields.decodeIfPresent(String.self, forKey: .skillLevel)

        try fields.resolveLink(forKey: .imageAsset, decoder: decoder) { [weak self] asset in
            self?.imageAsset = asset as? Asset
        }
        try fields.resolveLinksArray(forKey: .lessons, decoder: decoder) { [weak self] array in
            self?.lessons = array as? [Lesson]
        }
        try fields.resolveLinksArray(forKey: .categories, decoder: decoder) { [weak self] array in
            self?.categories = array as? [Category]
        }
    }

    enum Fields: String, CodingKey {
        case title, slug, shortDescription, duration, skillLevel, lessons, categories
        case imageAsset = "image"
        case courseDescription = "description"
    }
}
