
import UIKit
import DeepLinkKit
import Fabric
import Crashlytics

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    private(set) var services: ApplicationServices!
    private(set) var router: Router!
    private var deepLinkRouter: DPLDeepLinkRouter!
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Analytics events are only sent for app store builds. Non are sent from debug builds during development.
        Analytics.shared.setup()

        // Setup Crashlytics.
        Fabric.with([Crashlytics.self])

        deepLinkRouter = DPLDeepLinkRouter()

        let session = Session()
        
        // Setup the router with the necessary services.
        services = ApplicationServices(session: session)
        router = Router(services: services, deepLinkRouter: deepLinkRouter)

        // Customize the appearance of the app.
        UIApplication.customizeAppearance()

        // Pull the root view controller from the router and display the app on the screen.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = router.rootViewController
        window?.makeKeyAndVisible()

        return true
    }

    // Handle regular deep links: i.e. the-example-app.swift://route
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        deepLinkRouter.handle(url, withCompletion: nil)
    }

    // Handle universal links: i.e. https://the-example-app.swift.herokuapp.com/route
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        deepLinkRouter.handle(userActivity, withCompletion: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Reinit the session anytime user uses app again.
        services.session = Session()
    }
}
