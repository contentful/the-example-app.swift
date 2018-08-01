
import Foundation
import Contentful
import Interstellar

/// A small wrapper around the credentials for a space.
struct ContentfulCredentials: Codable, Equatable {

    static func ==(lhs: ContentfulCredentials, rhs: ContentfulCredentials) -> Bool {
        return lhs.spaceId == rhs.spaceId && lhs.deliveryAPIAccessToken == rhs.deliveryAPIAccessToken && lhs.previewAPIAccessToken == rhs.previewAPIAccessToken
    }

    static let defaultDomainHost = "contentful.com"

    let spaceId: String
    let deliveryAPIAccessToken: String
    let previewAPIAccessToken: String
    let domainHost: String

    /**
     * Pulls the default space credentials from the Example App Space owned by Contentful.
     */
    static let `default`: ContentfulCredentials = {
        guard let bundleInfo = Bundle.main.infoDictionary else { fatalError() }

        let spaceId = bundleInfo["CONTENTFUL_SPACE_ID"] as! String
        let deliveryAPIAccessToken = bundleInfo["CONTENTFUL_DELIVERY_TOKEN"] as! String
        let previewAPIAccessToken = bundleInfo["CONTENTFUL_PREVIEW_TOKEN"] as! String

        let credentials = ContentfulCredentials(spaceId: spaceId,
                                                deliveryAPIAccessToken: deliveryAPIAccessToken,
                                                previewAPIAccessToken: previewAPIAccessToken,
                                                domainHost: ContentfulCredentials.defaultDomainHost)
        return credentials
    }()

}

/// Tests credentials for validity and wraps relevant errors.
struct CredentialsTester {

    struct Error: Swift.Error {
        var errorMessages: [ErrorKey: String]
        var spaceId: String?
        var deliveryAccessToken: String?
        var previewAccessToken: String?

        init(errors: [ErrorKey: String]) {
            self.errorMessages = errors
        }
    }


    enum ErrorKey: String {
        case spaceId
        case deliveryAccessToken
        case previewAccessToken

        var hashValue: Int {
            return rawValue.hashValue
        }
    }

    /// Make two synchronous, blocking requests to validate the credentials with the Delivery and Preview APIs.
    static func testCredentials(credentials: ContentfulCredentials, services: Services) -> Result<ContentfulService> {

        let newContentfulService = ContentfulService(session: services.session,
                                                     credentials: credentials,
                                                     state: services.contentful.stateMachine.state)


        var errors = CredentialsTester.makeTestCalls(testContentfulService: newContentfulService, services: services)
        errors = errors + CredentialsTester.makeTestCalls(testContentfulService: newContentfulService, services: services, toPreviewAPI: true)

        // If there are no errors, assign a new service
        if errors.isEmpty {
            return Result.success(newContentfulService)
        } else {
            var error = CredentialsTester.Error(errors: errors)
            error.spaceId = credentials.spaceId
            error.deliveryAccessToken = credentials.deliveryAPIAccessToken
            error.previewAccessToken = credentials.previewAPIAccessToken

            return Result.error(error)
        }
    }

    // Blocking method to validate if credentials are valid against either the Delivery or Preview API.
    private static func makeTestCalls(testContentfulService: ContentfulService,
                                      services: Services,
                                      toPreviewAPI: Bool = false) -> [ErrorKey: String] {

        let semaphore = DispatchSemaphore(value: 0)
        let client = toPreviewAPI ? testContentfulService.previewClient : testContentfulService.deliveryClient

        var errors = [ErrorKey: String]()

        client.fetchSpace { result in

            switch result {
            case .success:
                errors.removeValue(forKey: .spaceId)
                if toPreviewAPI {
                    errors.removeValue(forKey: .previewAccessToken)
                } else {
                    errors.removeValue(forKey: .deliveryAccessToken)
                }
            case .error(let error):
                if let error = error as? APIError {
                    if error.statusCode == 401 {
                        if toPreviewAPI {
                            errors[.previewAccessToken] = "previewKeyInvalidLabel".localized(contentfulService: services.contentful)
                        } else {
                            errors[.deliveryAccessToken] = "deliveryKeyInvalidLabel".localized(contentfulService: services.contentful)
                        }
                    }
                    if error.statusCode == 404 {
                        errors[.spaceId] = "spaceOrTokenInvalid".localized(contentfulService: services.contentful)
                    }
                }
            }
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return errors
    }
}

@discardableResult internal func +=<K, V> (left: [K: V], right: [K: V]) -> [K: V] {
    var result = left
    right.forEach { (key, value) in result[key] = value }
    return result
}

@discardableResult internal func +<K, V> (left: [K: V], right: [K: V]) -> [K: V] {
    return left += right
}
