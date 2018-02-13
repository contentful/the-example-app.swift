
import Foundation
import UIKit
import DeepLinkKit
import Contentful
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
        if let tabBarController = rootViewController.viewController as? TabBarController {
            completion?(tabBarController)
            return
        }
        let tabBarController = TabBarController(services: services)
        rootViewController.set(viewController: tabBarController)
    }

    func showBlockingLoadingModal() -> UIView {
        let loadingOverlay = UIView.loadingOverlay(frame: rootViewController.view.frame)

        DispatchQueue.main.async { [unowned self] in
            self.rootViewController.view.addSubview(loadingOverlay)
        }
        return loadingOverlay
    }

    // MARK: DeepLink Parameters

    func updateSessionWithParameters(in deepLink: DPLDeepLink) {
        // Only trigger observations once.
        if willUpdateContentfulCredentialsAndShowAlerts(in: deepLink) {
            return
        }

        let editorialState = editorialFeaturesState(from: deepLink)
        services.session.persistEditorialFeatureState(isOn: editorialState)

        let state = ContentfulService.State(api: apiState(from: deepLink),
                                            locale: localeState(from: deepLink),
                                            editorialFeaturesEnabled: editorialState)
        services.contentful.stateMachine.state = state
    }

    func willUpdateContentfulCredentialsAndShowAlerts(in deepLink: DPLDeepLink) -> Bool {
        guard let spaceId = deepLink.queryParameters["space_id"] as? String,
            let deliveryToken = deepLink.queryParameters["delivery_token"] as? String,
            let previewToken = deepLink.queryParameters["preview_token"] as? String else {
                return false
        }

        let loadingOverlay = showBlockingLoadingModal()

        DispatchQueue.global(qos: .background).async { [unowned self] in
            let testCredentials = ContentfulCredentials(spaceId: spaceId,
                                                        deliveryAPIAccessToken: deliveryToken,
                                                        previewAPIAccessToken: previewToken)
            let testResults = CredentialsTester.testCredentials(credentials: testCredentials, services: self.services)

            DispatchQueue.main.async {
                loadingOverlay.removeFromSuperview()
            }

            switch testResults {
            case .success(let newContentfulService):

                let editorialState = self.editorialFeaturesState(from: deepLink)
                self.services.session.persistEditorialFeatureState(isOn: editorialState)

                let state = ContentfulService.State(api: self.apiState(from: deepLink),
                                                    locale: self.localeState(from: deepLink),
                                                    editorialFeaturesEnabled: editorialState)
                newContentfulService.stateMachine.state = state

                self.services.contentful = newContentfulService
                self.services.session.spaceCredentials = testCredentials
                self.services.session.persistCredentials()
                let alertController = UIAlertController.credentialSuccess(credentials: testCredentials)
                self.rootViewController.present(alertController, animated: true, completion: nil)

            case .error(let error):
                let error = error as! CredentialsTester.Error
                let alertController = UIAlertController.credentialsErrorAlertController(error: error)
                self.rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
        return true
    }

    func editorialFeaturesState(from deepLink: DPLDeepLink) -> Bool {
        guard let enableEditorialFeatures = deepLink.queryParameters["editorial_features"] as? String else {
            // Return current state if no link parameters present.
            return services.contentful.stateMachine.state.editorialFeaturesEnabled
        }

        if enableEditorialFeatures == "enabled" {
            return true
        } else if enableEditorialFeatures == "disabled" {
            return false
        }
        return false
    }

    /**
     
     */
    func apiState(from deepLink: DPLDeepLink) -> ContentfulService.State.API {
        guard let api = deepLink.queryParameters["api"] as? String else {
            // Return current state if no link parameters present.
            return services.contentful.stateMachine.state.api
        }

        if api == "cpa" {
            return .preview
        } else if api == "cda" {
            return .delivery
        }
        return .delivery
    }

    func localeState(from deepLink: DPLDeepLink) -> Contentful.Locale {
        guard let locale = deepLink.queryParameters["locale"] as? String else {
            // Return current state if no link parameters present.
            return services.contentful.stateMachine.state.locale
        }

        if locale == Contentful.Locale.americanEnglish().code {
            return .americanEnglish()
        } else if locale == Contentful.Locale.german().code {
            return .german()
        }
        return .americanEnglish()
    }

    // MARK: Routes

    func routes() -> [String: DPLRouteHandlerBlock] {
        return [
            // Home. ".*" resolves to the empty route "the-example-app.swift://"
            ".*": { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }
                self.updateSessionWithParameters(in: deepLink)
                self.showTabBarController() { tabBarController in
                    tabBarController.showHomeViewController()
                }
            },

            // All courses route.
            "courses" : { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }
                self.updateSessionWithParameters(in: deepLink)
                self.showTabBarController() { tabBarController in
                    tabBarController.showCoursesViewController()
                }
            },

            // Route to a specific course.
            "courses/:slug": { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                self.updateSessionWithParameters(in: deepLink)
                self.showTabBarController() { tabBarController in
                    tabBarController.showCoursesViewController() { coursesViewController in
                        guard let slug = deepLink.routeParameters["slug"] as? String else { return }
                        let courseViewController = CourseViewController(course: nil, services: self.services)
                        coursesViewController.navigationController?.pushViewController(courseViewController, animated: false)
                        courseViewController.fetchCourseWithSlug(slug)
                    }
                }
            },

            // Route to a specific lesson in a course.
            "courses/:courseSlug/lessons/:lessonSlug": { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                self.updateSessionWithParameters(in: deepLink)
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

            // The settings screen.
            "settings": { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                self.updateSessionWithParameters(in: deepLink)
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
