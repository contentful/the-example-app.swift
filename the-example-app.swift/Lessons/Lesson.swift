
import Foundation
import Contentful

class Lesson: NSObject, EntryDecodable, EntryQueryable, StatefulResource {

    static let contentTypeId = "lesson"

    let sys: Sys
    let title: String
    let slug: String
    var modules: [LessonModule]?

    var state = ResourceState.upToDate

    required init(from decoder: Decoder) throws {

        sys             = try decoder.sys()
        let fields   = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        title           = try fields.decode(String.self, forKey: .title)
        slug            = try fields.decode(String.self, forKey: .slug)
        super.init()

        try fields.resolveLinksArray(forKey: .modules, decoder: decoder) { [weak self] array in
            self?.modules = array as? [LessonModule]
        }
    }

    enum Fields: String, CodingKey {
        case title, slug, modules
    }
}
