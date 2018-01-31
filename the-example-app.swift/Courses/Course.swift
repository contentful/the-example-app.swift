
import Foundation
import Contentful

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
