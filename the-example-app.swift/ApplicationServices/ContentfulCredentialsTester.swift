//
//  Copyright © 2020 Contentful. All rights reserved.
//

import Contentful
import Foundation

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
    static func testCredentials(credentials: ContentfulCredentials, services: ApplicationServices) -> Result<StatefulContentfulClientProvider, Error> {

        let newContentfulService = StatefulContentfulClientProvider(session: services.session,
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

            return .failure(error)
        }
    }

    // Blocking method to validate if credentials are valid against either the Delivery or Preview API.
    private static func makeTestCalls(testContentfulService: StatefulContentfulClientProvider,
                                      services: ApplicationServices,
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
            case .failure(let error):
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

func ==(lhs: ContentfulCredentials, rhs: ContentfulCredentials) -> Bool {
    return lhs.spaceId == rhs.spaceId && lhs.deliveryAPIAccessToken == rhs.deliveryAPIAccessToken && lhs.previewAPIAccessToken == rhs.previewAPIAccessToken
}

