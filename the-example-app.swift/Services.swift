
import Foundation

class Services {

    var session: Session
    
    var contentful: ContentfulService

    init(session: Session) {
        self.session = session
        let spaceCredentials = session.spaceCredentials
        contentful = ContentfulService(session: session,
                                       credentials: spaceCredentials,
                                       api: .delivery,
                                       editorialFeaturesEnabled: session.areEditorialFeaturesEnabled())
    }
}
