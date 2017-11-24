/**
 * Todo: this class should handle deep links.
 */

import Foundation
import UIKit

final class Router {

    let rootViewController: RootViewController

    let services: Services

    init(services: Services) {
        self.services = services
        self.rootViewController = RootViewController()

        // Show view controllers.
        showTabBarController()

        // Set state
        setupStateTransitions()
    }

    func setupStateTransitions() {
        services.contentful.apiStateMachine.addTransitionObservation(updateAPI(_:))
        services.contentful.localeStateMachine.addTransitionObservation(updateLocale(_:))
    }

    func updateAPI(_ observation: StateMachine<Contentful.State>.Transition) {
        print("Get here")
    }

    func updateLocale(_ observation: StateMachine<Contentful.Locale>.Transition) {
        print("Get here")
    }

    func showTabBarController() {
        let viewControllers: [UIViewController] = [
            //            UINavigationController(rootViewController: HomeViewController(contentful: services.contentful)),
            NavigationController(rootViewController: CoursesViewController(services: services), services: services),
            NavigationController(rootViewController: SettingsViewController(services: services), services: services)
        ]
        let tabBarController = TabBarController(services: services, viewControllers: viewControllers)
        rootViewController.set(viewController: tabBarController)
    }


    // MARK: Routing

    func handleDeepLink() {
        // Update session credentials
    }
}


protocol ContentfulPresentable {



}

class StateMachine<State>{

    struct Transition {
        let last: State
        let next: State
    }

    typealias TransitionObservation = (Transition) -> Void

    var state: State {
        didSet {
            for (_, observe) in self.observations {
                observe(Transition(last: oldValue, next: state))
            }
        }
    }

    func broadcast() {
        for (_, observer) in self.observations {
            observer(Transition(last: self.state, next: self.state))
        }
    }

    @discardableResult func addTransitionObservation(_ observation: @escaping TransitionObservation) -> String {
        let token = UUID().uuidString
        observations[token] = observation

        // Trigger the initial state being set.
        observation(Transition(last: state, next: state))
        return token
    }

    func stopObserving(token: String) {
        observations.removeValue(forKey: token)
    }


    private var observations: [String: TransitionObservation] = [:]

    init(initialState: State, observe: TransitionObservation? = nil) {
        self.state = initialState
        if let observer = observe {
            // Trigger the initial state being set.
            self.addTransitionObservation(observer)
        }
    }
}
