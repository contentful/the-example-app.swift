
import Foundation
import UIKit
import DeepLinkKit
import Contentful
import Interstellar


/// This class contains all the logic necessary to route the app to a specific screen with the proper underlying navigation stack and application state.
/// This class also maps URL strings [deep links] to said routes and will update the application state based on relevant url parameters parsed from deep links.
final class Router {

    /// A root container view controller to contain the application and simplify navigation transitions.
    let rootViewController: RootViewController

    let services: Services

    /// Router depends on DPLDeepLinkRouter to do pattern matching and routing for the urls that the operating system forwards
    /// the application. It also provides niceties for parsing url arguments.
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


    var tabBarController: TabBarController? {
        return rootViewController.viewController as? TabBarController
    }

    func showTabBarController(then completion: ((TabBarController) -> Void)? = nil) {
        if let tabBarController = self.tabBarController {
            completion?(tabBarController)
            return
        }
        let tabBarController = TabBarController(services: services)
        rootViewController.set(viewController: tabBarController)
    }

    func showSettings(error: Error?) {
        let credentialsError = error as? CredentialsTester.Error
        DispatchQueue.main.async {
            self.showTabBarController() { tabBarController in
                tabBarController.showSettingsViewController(credentialsError: credentialsError)
            }
        }
    }

    func showBlockingLoadingModal() -> UIView {
        let loadingOverlay = UIView.loadingOverlay(frame: rootViewController.view.frame)

        OperationQueue.main.addOperation { [unowned self] in
            self.rootViewController.view.addSubview(loadingOverlay)
        }
        return loadingOverlay
    }

    // MARK: DeepLink Parameters

    /// Given a deep link object, this method updates all the session state in the `session` property of the receiving Router.
    func updatedAllSessionParametersFound(in deepLink: DPLDeepLink, then completion: @escaping (Result<Bool>) -> Void) {

        let queryParameters: [String?] = [
            deepLink.queryParameters["space_id"] as? String,
            deepLink.queryParameters["delivery_token"] as? String,
            deepLink.queryParameters["preview_token"] as? String
        ]
        let wellFormedParameterCount = queryParameters.compactMap({ $0 }).filter({ $0.isEmpty == false }).count

        // If space credentials were in the deep link, ensure that they have all three required parameters,
        // otherwise, route to the settings page.
        guard wellFormedParameterCount == 0 || wellFormedParameterCount == 3 else {
            let credentialsError = partialCredentialsErrorFromDeepLink(deepLink)
            completion(Result.error(credentialsError))
            return
        }

        // If all three parameters are available, assign them, Now assign the remaining values and use them.
        guard let spaceId = deepLink.queryParameters["space_id"] as? String,
            let deliveryToken = deepLink.queryParameters["delivery_token"] as? String,
            let previewToken = deepLink.queryParameters["preview_token"] as? String else {

                // Assign new states to already assigned contentful service and trigger observations.
                updateStatesInServices(contentful: services.contentful, from: deepLink)
                completion(Result.success(true))
                return
        }

        let domainHost = deepLink.queryParameters["host"] as? String ?? ContentfulCredentials.defaultDomainHost
        
        let loadingOverlay = self.showBlockingLoadingModal()

        DispatchQueue.global(qos: .background).async { [unowned self] in
            let testCredentials = ContentfulCredentials(spaceId: spaceId,
                                                        deliveryAPIAccessToken: deliveryToken,
                                                        previewAPIAccessToken: previewToken,
                                                        domainHost: domainHost)
            let testResults = CredentialsTester.testCredentials(credentials: testCredentials, services: self.services)

            switch testResults {
            case .success(let newContentfulService):

                DispatchQueue.main.async {

                    // Assign states to new contentful service with no observations registered.
                    self.updateStatesInServices(contentful: newContentfulService, from: deepLink)

                    // Assign the new service to register new observations and trigger them.
                    self.services.contentful = newContentfulService

                    // We have validated our new credentials, we can now assign and persist them.
                    self.services.session.spaceCredentials = testCredentials
                    self.services.session.persistCredentials()


                    completion(Result.success(true))
                    
                    // Tell the user that we have successfully connect to a new space.
                    let alertController = AlertController.credentialSuccess(credentials: testCredentials)
                    self.rootViewController.present(alertController, animated: true, completion: nil)
                    self.tabBarController?.clearSettingsErrors()
                }

            case .error(let error):
                // Assign new states to already assigned contentful service and trigger observations.
                self.updateStatesInServices(contentful: self.services.contentful, from: deepLink)

                DispatchQueue.main.async {
                    completion(Result.error(error as! CredentialsTester.Error))
                }
            }
            DispatchQueue.main.async {
                loadingOverlay.removeFromSuperview()
            }
        }
    }

    func partialCredentialsErrorFromDeepLink(_ deepLink: DPLDeepLink) -> CredentialsTester.Error {
        var errors = [CredentialsTester.ErrorKey: String]()
        if deepLink.queryParameters["space_id"] == nil {
            errors[.spaceId] = "fieldIsRequiredLabel".localized(contentfulService: services.contentful) + ": " + "spaceIdLabel".localized(contentfulService: services.contentful)
        }

        if deepLink.queryParameters["delivery_token"] == nil {
            errors[.deliveryAccessToken] = "fieldIsRequiredLabel".localized(contentfulService: services.contentful) + ": " + "cdaAccessTokenLabel".localized(contentfulService: services.contentful)
        }

        if deepLink.queryParameters["preview_token"] == nil {
            errors[.previewAccessToken] = "fieldIsRequiredLabel".localized(contentfulService: services.contentful) + ": " + "cpaAccessTokenLabel".localized(contentfulService: services.contentful)
        }
        var error = CredentialsTester.Error(errors: errors)
        error.spaceId = deepLink.queryParameters["space_id"] as? String
        error.deliveryAccessToken = deepLink.queryParameters["delivery_token"] as? String
        error.previewAccessToken = deepLink.queryParameters["preview_token"] as? String

        return error
    }

    func updateStatesInServices(contentful: ContentfulService, from deepLink: DPLDeepLink) {
        // Also update editorial state.
        let editorialState = self.editorialFeaturesState(from: deepLink)
        services.session.persistEditorialFeatureState(isOn: editorialState)

        let state = ContentfulService.State(api: apiState(from: deepLink),
                                            locale: localeState(from: deepLink, newService: contentful),
                                            editorialFeaturesEnabled: editorialState)
        // Update
        contentful.stateMachine.state = state
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

    func localeState(from deepLink: DPLDeepLink, newService: ContentfulService) -> Contentful.Locale {
        guard let locale = deepLink.queryParameters["locale"] as? String else {
            // Return current state if no link parameters present, but check if locale is present first.
            if newService.locales.contains(services.contentful.stateMachine.state.locale) {
                return newService.stateMachine.state.locale
            }
            return .americanEnglish()
        }

        if locale == Contentful.Locale.americanEnglish().code {
            return .americanEnglish()
        } else if locale == Contentful.Locale.german().code {
            return .german()
        }
        return .americanEnglish()
    }

    // MARK: Routes

    /// All the url routes of the application and their corresponding router handler.
    /// This is an array of tuples rather than a dictionary since the order of the route registration is
    /// respected by DPLDeepLinkRouter: i.e. the first route that a url matches will be the route for which
    /// the handler is called. This is why the wildcard route ".*" is last.
    func routes() -> [(String, DPLRouteHandlerBlock)] {
        return [

            // All courses route.
            ("courses", { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                self.updatedAllSessionParametersFound(in: deepLink) { result in
                    switch result {
                    case .success:
                        self.showTabBarController() { tabBarController in
                            tabBarController.showCoursesViewController()
                        }
                    case .error(let error):
                        self.showSettings(error: error)
                    }
                }
            }),

            // Route to a specific course.
            ("courses/:slug", { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                self.updatedAllSessionParametersFound(in: deepLink) { result in
                    switch result {
                    case .success:
                        self.showTabBarController() { tabBarController in
                            tabBarController.showCoursesViewController() { coursesViewController in
                                guard let slug = deepLink.routeParameters["slug"] as? String else { return }
                                let courseViewController = CourseViewController(course: nil, services: self.services)
                                coursesViewController.navigationController?.pushViewController(courseViewController, animated: false)
                                courseViewController.fetchCourseWithSlug(slug)
                            }
                        }
                    case .error(let error):
                        self.showSettings(error: error)
                    }
                }
            }),

            // Route to a specific lesson in a course.
            ("courses/:courseSlug/lessons/:lessonSlug", { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                self.updatedAllSessionParametersFound(in: deepLink) { result in
                    switch result {
                    case .success:
                        self.showTabBarController() { tabBarController in
                            tabBarController.showCoursesViewController { coursesViewController in
                                guard let courseSlug = deepLink.routeParameters["courseSlug"] as? String else { return }
                                let lessonSlug = deepLink.routeParameters["lessonSlug"] as? String

                                // Push Course View Controller
                                let courseViewController = CourseViewController(course: nil, services: self.services)
                                coursesViewController.navigationController?.pushViewController(courseViewController, animated: false)
                                // Present the lessons view controller even before making the network request.
                                courseViewController.pushLessonsCollectionViewAndShowLesson(at: 0, animated: false)
                                courseViewController.fetchCourseWithSlug(courseSlug, showLessonWithSlug: lessonSlug)
                            }
                        }
                    case .error(let error):
                        self.showSettings(error: error)
                    }
                }
            }),

            // Categories route.
            ("courses/categories/:categorySlug", { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                self.updatedAllSessionParametersFound(in: deepLink) { result in
                    switch result {
                    case .success:
                        self.showTabBarController() { tabBarController in
                            tabBarController.showCoursesViewController { coursesViewController in
                                guard let categorySlug = deepLink.routeParameters["categorySlug"] as? String else { return }

                                coursesViewController.onCategoryAppearance = { categories in
                                    if let category = categories.filter({ $0.slug == categorySlug}).first {
                                        coursesViewController.select(category: category)
                                    }
                                }
                            }
                        }

                    case .error(let error):
                        self.showSettings(error: error)
                    }
                }
            }),

            // The settings screen.
            ("settings", { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                self.updatedAllSessionParametersFound(in: deepLink) { result in
                    switch result {
                    case .success:
                        self.showSettings(error: nil)
                    case .error(let error):
                        self.showSettings(error: error)
                    }
                }
            }),
            
            // Home. "." resolves to the empty route "the-example-app.swift://"
            (".*", { [unowned self] deepLink in
                guard let deepLink = deepLink else { return }

                var isHomeRoute = deepLink.url.host == nil
                if let host = deepLink.url.host, host.isEmpty == true {
                    isHomeRoute = true
                }
                // Home route.
                if isHomeRoute {

                    self.updatedAllSessionParametersFound(in: deepLink) { result in
                        switch result {
                        case .success:
                            self.showTabBarController() { tabBarController in
                                tabBarController.showHomeViewController()
                            }
                        case .error(let error):
                            self.showSettings(error: error)
                        }
                    }
                } else {
                    // Other non-supported routes.
                    let error = NoContentError.invalidRoute(contentfulService: self.services.contentful, route: deepLink.url.host!, fontSize: 14.0)
                    let alertController = AlertController.noContentErrorAlertController(error: error)
                    self.rootViewController.present(alertController, animated: true, completion: nil)
                }
            })
        ]
    }
}

extension DPLDeepLinkRouter {

    // Register an array of tuples rather than using a dictionary to ensure
    // that the registration order is respected as DeepLinkKit respects this ordering.
    func registerRoutes(routes: [(String, DPLRouteHandlerBlock)]) {
        for (route, handler) in routes {
            self.register(handler, forRoute: route)
        }
    }
}
