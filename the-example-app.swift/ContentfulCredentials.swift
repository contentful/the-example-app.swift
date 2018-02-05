
import Foundation
import Contentful
import Interstellar

struct ContentfulCredentials: Codable, Equatable {

    static func ==(lhs: ContentfulCredentials, rhs: ContentfulCredentials) -> Bool {
        return lhs.spaceId == rhs.spaceId && lhs.deliveryAPIAccessToken == rhs.deliveryAPIAccessToken && lhs.previewAPIAccessToken == rhs.previewAPIAccessToken
    }


    let spaceId: String
    let deliveryAPIAccessToken: String
    let previewAPIAccessToken: String

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
                                                previewAPIAccessToken: previewAPIAccessToken)
        return credentials
    }()

}

struct CredentialsTester {

    struct Error: Swift.Error {
        var errors: [ErrorKey: String]
    }

    enum ErrorKey: String {
        case spaceId
        case deliveryAccessToken
        case previewAccessToken

        var hashValue: Int {
            return rawValue.hashValue
        }
    }

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
            return Result.error(CredentialsTester.Error(errors: errors))
        }
    }

    // Blocking method to validate if credentials are valid
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
