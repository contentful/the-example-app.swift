
import Foundation
import Firebase

class Analytics {

    static let shared = Analytics()


    func setup() {
        #if Release
            // Configure analytics only for app store builds.
            FirebaseApp.configure()
            AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(true)
        #else
            AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(false)
        #endif
    }

    func logViewedRoute(_ route: String) {
        #if Release
            Firebase.Analytics.logEvent(route, parameters: nil)
        #endif
    }
}
