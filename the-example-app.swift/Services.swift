
import Foundation
import Contentful

/// A class that acts as a service bus, bussing around services down through the various components of the app.
class Services {

    public var session: Session
    
    public var contentful: ContentfulService {
        didSet {
            contentfulStateMachine.state = contentful
        }
    }

    public let contentfulStateMachine: StateMachine<ContentfulService>

    public func resetCredentialsAndLocaleToDefault() {
        let defaultCredentials = ContentfulCredentials.default

        // Retain state from last ContentfulService, but ensure we are using a locale that is available in default space.
        var state = contentful.stateMachine.state
        let availableLocales = [Contentful.Locale.americanEnglish(), Contentful.Locale.german()]
        state.locale = availableLocales.contains(contentful.stateMachine.state.locale) ? contentful.stateMachine.state.locale : Contentful.Locale.americanEnglish()
        contentful = ContentfulService(session: session,
                                       credentials: defaultCredentials,
                                       state: state)

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
