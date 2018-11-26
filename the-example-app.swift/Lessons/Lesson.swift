
import Foundation
import Contentful

class Lesson: NSObject, EntryDecodable, Resource, FieldKeysQueryable, StatefulResource {

    static let contentTypeId = "lesson"

    let sys: Sys
    let title: String
    let slug: String
    let richText: RichTextDocument?

    var state = ResourceState.upToDate

    required init(from decoder: Decoder) throws {
        sys             = try decoder.sys()
        let fields      = try decoder.contentfulFieldsContainer(keyedBy: FieldKeys.self)
        title           = try fields.decode(String.self, forKey: .title)
        slug            = try fields.decode(String.self, forKey: .slug)
        richText        = try fields.decodeIfPresent(RichTextDocument.self, forKey: .copy)

        super.init()
    }

    enum FieldKeys: String, CodingKey {
        case title, slug, copy
    }
}
