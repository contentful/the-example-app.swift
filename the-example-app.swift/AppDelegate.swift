
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var services: Services!

    var router: Router!


    // MARK: UIApplicationDelegate

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let session = Session()
        // Setup the router with the necessary services.
        services = Services(session: session)
        router = Router(services: services)

        // Customize the appearance of the app.
        UIApplication.customizeAppearance()

        // Pull the root view controller from the router and display the app on the screen.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = router.rootViewController
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}
