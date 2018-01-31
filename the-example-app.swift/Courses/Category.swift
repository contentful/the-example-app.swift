
import Foundation
import Contentful

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

extension Category: Equatable {
    static func ==(lhs: Category, rhs: Category) -> Bool {
        return rhs.id == lhs.id && rhs.localeCode == lhs.localeCode
    }
}
