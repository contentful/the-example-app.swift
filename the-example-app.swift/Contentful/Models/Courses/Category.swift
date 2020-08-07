
import Foundation
import Contentful

class Category: EntryDecodable, Resource, FieldKeysQueryable, StatefulResource {

    static let contentTypeId = "category"

    let sys: Sys
    let slug: String
    let title: String

    var state = ResourceState.upToDate

    required init(from decoder: Decoder) throws {
        sys             = try decoder.sys()
        let container   = try decoder.contentfulFieldsContainer(keyedBy: FieldKeys.self)
        title           = try container.decode(String.self, forKey: .title)
        slug            = try container.decode(String.self, forKey: .slug)
    }

    enum FieldKeys: String, CodingKey {
        case slug, title
    }
}

extension Category: Equatable {}

func ==(lhs: Category, rhs: Category) -> Bool {
    return rhs.id == lhs.id && rhs.localeCode == lhs.localeCode
}
