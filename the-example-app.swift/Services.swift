
import Foundation

class Services {

    var session: Session
    
    var contentful: ContentfulService {
        didSet {
            contentfulStateMachine.state = contentful
        }
    }

    let contentfulStateMachine: StateMachine<ContentfulService>

    init(session: Session) {
        self.session = session
        let spaceCredentials = session.spaceCredentials
        let state = ContentfulService.State(api: .delivery,
                                            locale: .americanEnglish(),
                                            editorialFeaturesEnabled: session.areEditorialFeaturesEnabled())
        contentful = ContentfulService(session: session,
                                       credentials: spaceCredentials,
                                       state: state)
        contentfulStateMachine = StateMachine(initialState: contentful)
    }
}
