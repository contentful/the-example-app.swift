//
//  AppDelegate.swift
//  the-example-app.swift
//
//  Created by JP Wright on 14.11.17.
//  Copyright © 2017 Contentful. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var serviceBus: ServiceBus!

    var router: Router!


    // MARK: UIApplicationDelegate

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let session = Session()
        // Setup the router with the necessary services.
        serviceBus = ServiceBus(session: session)
        router = Router(serviceBus: serviceBus)

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

