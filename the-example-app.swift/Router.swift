/**
 * Todo: this class should handle deep links.
 */

import Foundation
import UIKit
import DeepLinkKit
import Interstellar

final class Router {

    let rootViewController: RootViewController

    let services: Services

    let deepLinkRouter: DPLDeepLinkRouter

    init(services: Services, deepLinkRouter: DPLDeepLinkRouter) {
        self.services = services
        self.rootViewController = RootViewController()

        // Register deep link routes.
        self.deepLinkRouter = deepLinkRouter
        self.deepLinkRouter.registerRoutes(routes: routes())

        // Show view controllers.
        showTabBarController()
    }

    func showTabBarController(then completion: ((TabBarController) -> Void)? = nil) {
        let tabBarController = TabBarController(services: services)
        rootViewController.set(viewController: tabBarController)
        completion?(tabBarController)
    }

    func updateSessionWithCredentials(in deepLink: DPLDeepLink) {
//        if let spaceId = deepLink.queryParameters["space_id"] {
//
//        }
//        if let deliveryToken = deepLink.queryParameters["delivery_token"] {
//
//        }
//        if let previewToken = deepLink.queryParameters["preview_token"] {
//
//        }
//        if let enableEditorialFeatures = deepLink.queryParameters["enable_editorial_features"] {
//
//        }
//        if let api = deepLink.queryParameters["api"] {
//
//            // cpa or cda
//        }
//        if let locale = deepLink.queryParameters["locale"] {
//            // en-US de-DE
//        }
    }

    // MARK: Routes

    func routes() -> [String: DPLRouteHandlerBlock] {
        return [
            // Home.
            "": { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }
                self.updateSessionWithCredentials(in: deepLink)
                self.showTabBarController() { tabBarController in
                    tabBarController.showHomeViewController()
                }
            },

            // Courses route.
            "courses" : { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }
                self.updateSessionWithCredentials(in: deepLink)
                self.showTabBarController() { tabBarController in
                    tabBarController.showCoursesViewController()
                }
            },

            "courses/:slug": { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                self.updateSessionWithCredentials(in: deepLink)
                self.showTabBarController() { tabBarController in
                    tabBarController.showCoursesViewController() { coursesViewController in
                        guard let slug = deepLink.routeParameters["slug"] as? String else { return }
                        let courseViewController = CourseViewController(course: nil, services: self.services)
                        coursesViewController.navigationController?.pushViewController(courseViewController, animated: false)
                        courseViewController.fetchCourseWithSlug(slug)
                    }
                }
            },

            "courses/:courseSlug/lessons/:lessonSlug": { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                self.updateSessionWithCredentials(in: deepLink)
                self.showTabBarController() { tabBarController in
                    tabBarController.showCoursesViewController() { coursesViewController in
                        guard let courseSlug = deepLink.routeParameters["courseSlug"] as? String else { return }
                        let lessonSlug = deepLink.routeParameters["lessonSlug"] as? String

                        // Push Course View Controller
                        let courseViewController = CourseViewController(course: nil, services: self.services)
                        coursesViewController.navigationController?.pushViewController(courseViewController, animated: false)
                        // Present the lessons view controller even before making the network request.
                        courseViewController.pushLessonsCollectionViewAndShowLesson(at: 0)
                        courseViewController.fetchCourseWithSlug(courseSlug, showLessonWithSlug: lessonSlug)
                    }
                }
            },

            "settings": { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                self.updateSessionWithCredentials(in: deepLink)
                self.showTabBarController() { tabBarController in
                    tabBarController.showSettingsViewController()
                }
            }
        ]
    }
}

extension DPLDeepLinkRouter {

    func registerRoutes(routes: [String: DPLRouteHandlerBlock]) {
        for (route, handler) in routes {
            self.register(handler, forRoute: route)
        }
    }
}
