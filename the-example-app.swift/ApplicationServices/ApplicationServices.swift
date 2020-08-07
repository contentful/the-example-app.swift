
import Foundation
import Contentful

/// A class that acts as a service bus, bussing around services down through the various components of the app.
class ApplicationServices {

    public var session: Session
    
    public var contentful: StatefulContentfulClientProvider {
        didSet {
            contentfulStateMachine.state = contentful
        }
    }

    public let contentfulStateMachine: StateMachine<StatefulContentfulClientProvider>

    public func resetCredentialsAndResetLocaleIfNecessary() {
        let defaultCredentials = ContentfulCredentials.default

        // Retain state from last ContentfulService, but ensure we are using a locale that is available in default space.
        var state = contentful.stateMachine.state
        let availableLocales = [Contentful.Locale.americanEnglish(), Contentful.Locale.german()]
        state.locale = availableLocales.contains(contentful.stateMachine.state.locale) ? contentful.stateMachine.state.locale : Contentful.Locale.americanEnglish()
        contentful = StatefulContentfulClientProvider(session: session,
                                       credentials: defaultCredentials,
                                       state: state)

        session.spaceCredentials = defaultCredentials
        session.persistCredentials()
    }

    init(session: Session) {
        self.session = session
        let spaceCredentials = session.spaceCredentials

        let api = StatefulContentfulClientProvider.State.API(rawValue: session.persistedAPIRawValue() ?? StatefulContentfulClientProvider.State.API.delivery.rawValue)!
        let state = StatefulContentfulClientProvider.State(api: api,
                                            locale: .americanEnglish(),
                                            editorialFeaturesEnabled: session.areEditorialFeaturesEnabled())
        contentful = StatefulContentfulClientProvider(session: session,
                                       credentials: spaceCredentials,
                                       state: state)
        if let persistedLocaleCode = session.persistedLocaleCode(), let index = contentful.locales.map({ $0.code }).index(of: persistedLocaleCode) {
            contentful.setLocale(contentful.locales[index])
        } else {
            contentful.setLocale(.americanEnglish())
        }
        contentfulStateMachine = StateMachine(initialState: contentful)
    }
}
