//
//  MockOAuthService.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/8/21.
//

import Foundation
@testable import SensoryCloud
import GRPC
import NIO

class MockOAuthService: OAuthService {

    let mockGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)

    var clientID: String?
    var secret: String?

    var response: Sensory_Api_Common_TokenResponse?
    var networkError: Error?

    override func getToken(clientID: String, secret: String) -> EventLoopFuture<Sensory_Api_Common_TokenResponse> {
        self.clientID = clientID
        self.secret = secret

        if let rsp = response {
            return mockGroup.next().makeSucceededFuture(rsp)
        }

        return mockGroup.next().makeFailedFuture(networkError ?? NetworkError.notInitialized)
    }

    func reset() {
        clientID = nil
        secret = nil
        response = nil
        networkError = nil
    }
}
