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
    var name: String?
    var credential: String?

    var response: Sensory_Api_Common_TokenResponse?
    var enrollResponse: Sensory_Api_V1_Management_DeviceResponse?
    var renewResponse: Sensory_Api_V1_Management_DeviceResponse?
    var networkError: Error?

    override func getToken(clientID: String, secret: String) -> EventLoopFuture<Sensory_Api_Common_TokenResponse> {
        self.clientID = clientID
        self.secret = secret

        if let rsp = response {
            return mockGroup.next().makeSucceededFuture(rsp)
        }

        return mockGroup.next().makeFailedFuture(networkError ?? NetworkError.notInitialized)
    }

    override func enrollDevice(name: String, credential: String, clientID: String, clientSecret: String) -> EventLoopFuture<Sensory_Api_V1_Management_DeviceResponse> {
        self.name = name
        self.credential = credential
        self.clientID = clientID
        self.secret = clientSecret

        if let rsp = enrollResponse {
            return mockGroup.next().makeSucceededFuture(rsp)
        }

        return mockGroup.next().makeFailedFuture(networkError ?? NetworkError.notInitialized)
    }

    override func renewDeviceCredential(clientID: String, credential: String) -> EventLoopFuture<Sensory_Api_V1_Management_DeviceResponse> {
        self.clientID = clientID
        self.credential = credential

        if let rsp = renewResponse {
            return mockGroup.next().makeSucceededFuture(rsp)
        }

        return mockGroup.next().makeFailedFuture(networkError ?? NetworkError.notInitialized)
    }

    func reset() {
        clientID = nil
        secret = nil
        name = nil
        credential = nil
        response = nil
        enrollResponse = nil
        renewResponse = nil
        networkError = nil
    }
}
