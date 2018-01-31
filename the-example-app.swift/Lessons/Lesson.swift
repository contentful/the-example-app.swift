
import Foundation
import Contentful

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
