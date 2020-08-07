
import Foundation
import FirebaseAnalytics
import FirebaseCore
import SnowplowTracker

/// A wrapper class for sending analytics events used by Contentful to see if this example app adequately helps
/// teach new users about the platform. Events are only ever sent in "Release" builds so you can be sure that if you
/// run this project locally on your machine, no data will be sent.
class Analytics {

    static let shared = Analytics()

    private lazy var snowplowEmitter: SPEmitter = {
        let emitter = SPEmitter.build { builder in
            builder!.setUrlEndpoint("col.contentful.com")
        }
        return emitter!
    }()

    private lazy var snowplowTracker: SPTracker = {
        let tracker = SPTracker.build { [unowned self] builder in
            builder!.setEmitter(self.snowplowEmitter)
            builder!.setAppId("the-example-app")
        }
        return tracker!
    }()

    func setup() {
        #if Release
            // Configure analytics only for app store builds.
            FirebaseApp.configure()
            FirebaseAnalytics.Analytics.setAnalyticsCollectionEnabled(true)
        #else
            // Don't send any analytics regarding users who have checked out source code.
            FirebaseAnalytics.Analytics.setAnalyticsCollectionEnabled(false)
        #endif
    }

    func logViewedRoute(_ route: String, spaceId: String) {
        #if Release
            // Snowplow events.
            let data = NSDictionary(dictionary: [
                "space_id": spaceId,
                "sdk_language_used": "swift",
                "app_framework": "Cocoa"
            ])
            let schema = "iglu:com.contentful/app_the_example_app_open/jsonschema/1-0-0"
            let selfDescribingJSON = SPSelfDescribingJson(schema: schema, andData: data)!

            // In snowplow terms, and SPUnstructured == a self-describing event.
            let selfDescribingEvent = SPUnstructured.build { builder in
                builder!.setEventData(selfDescribingJSON)
            }
            snowplowTracker.trackUnstructuredEvent(selfDescribingEvent)

            let pageViewEvent = SPPageView.build { builder in
                builder!.setPageUrl(route)
            }
            snowplowTracker.trackPageViewEvent(pageViewEvent!)

            // Firebase.
            Firebase.Analytics.logEvent(route, parameters: nil)
        #endif
    }
}
