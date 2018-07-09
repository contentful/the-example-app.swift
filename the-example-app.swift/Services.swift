
import Foundation

/// A class that acts as a service bus, bussing around services down through the various components of the app.
class Services {

    public var session: Session
    
    public var contentful: ContentfulService {
        didSet {
            contentfulStateMachine.state = contentful
        }
    }

    public let contentfulStateMachine: StateMachine<ContentfulService>

    public func resetCredentialsToDefault() {
        let defaultCredentials = ContentfulCredentials.default
        contentful = ContentfulService(session: session,
                                       credentials: defaultCredentials,
                                       state: contentful.stateMachine.state)

        session.spaceCredentials = defaultCredentials
        session.persistCredentials()
    }

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
