
import Foundation
import Contentful

class HomeLayout: NSObject, EntryDecodable, EntryQueryable, StatefulResource {

    static let contentTypeId = "layout"

    let sys: Sys
    let slug: String
    var modules: [LayoutModule]?

    var state = ResourceState.upToDate

    required init(from decoder: Decoder) throws {
        sys             = try decoder.sys()

        let fields      = try decoder.contentfulFieldsContainer(keyedBy: Fields.self)
        slug            = try fields.decode(String.self, forKey: .slug)

        super.init()

        try fields.resolveLinksArray(forKey: .modules, decoder: decoder) { [weak self] array in
            self?.modules = array as? [LayoutModule]
        }
    }

    enum Fields: String, CodingKey {
        case slug
        case modules = "contentModules"
    }
}
