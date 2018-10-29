
import UIKit
import DeepLinkKit
import Firebase
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var services: Services!

    var router: Router!

    var deepLinkRouter: DPLDeepLinkRouter!


    // MARK: UIApplicationDelegate

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Analytics events are only sent for app store builds. Non are sent from debug builds during development.
        Analytics.shared.setup()

        // Setup Crashlytics.
        Fabric.with([Crashlytics.self])

        deepLinkRouter = DPLDeepLinkRouter()

        let session = Session()
        
        // Setup the router with the necessary services.
        services = Services(session: session)
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
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return deepLinkRouter.handle(url, withCompletion: nil)
    }

    // Handle universal links: i.e. https://the-example-app.swift.herokuapp.com/route
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return deepLinkRouter.handle(userActivity, withCompletion: nil)
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Reinit the session anytime user uses app again.
        services.session = Session()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}
