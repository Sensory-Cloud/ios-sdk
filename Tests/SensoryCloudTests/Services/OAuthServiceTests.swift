//
//  OAuthServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/12/21.
//

import XCTest
@testable import SensoryCloud

final class OAuthServiceTests: XCTestCase {

    var expectResponse = XCTestExpectation(description: "grpc response should be received")
    var expectRequestMetadata = XCTestExpectation(description: "request metadata should be sent")
    var expectRequest = XCTestExpectation(description: "grpc request should be sent")

    override func setUp() {
        resetExpectation()
        Config.cloudHost = nil
    }

    func resetExpectation() {
        expectResponse = XCTestExpectation(description: "grpc response should be received")
        expectRequestMetadata = XCTestExpectation(description: "request metadata should be sent")
        expectRequest = XCTestExpectation(description: "grpc request should be sent")
    }

    func testGetToken() throws {
        let mockClient = Sensory_Api_Oauth_OauthServiceTestClient()
        let oauthService = OAuthServiceMockClient(client: mockClient)

        Config.setCloudHost(host: "Some Host", port: 123)

        var expectedResponse = Sensory_Api_Common_TokenResponse()
        expectedResponse.accessToken = "Mock Access Token"
        expectedResponse.expiresIn = 500
        expectedResponse.tokenType = "Bearer"
        expectedResponse.keyID = "Key ID"

        var expectedRequest = Sensory_Api_Oauth_TokenRequest()
        expectedRequest.clientID = "client ID"
        expectedRequest.secret = "client secret"

        let mockStream = mockClient.makeGetTokenResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssert(headers.isEmpty, "Standard auth header should not be sent")
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                break
            }
        }

        let rsp = oauthService.getToken(clientID: "client ID", secret: "client secret")
        try mockStream.sendMessage(expectedResponse)
        rsp.whenSuccess { [weak self] enrollments in
            XCTAssertEqual(expectedResponse, enrollments)
            self?.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testGetTokenMissingHost() throws {
        let mockClient = Sensory_Api_Oauth_OauthServiceTestClient()
        let oauthService = OAuthServiceMockClient(client: mockClient)

        let mockStream = mockClient.makeGetTokenResponseStream { _ in
            XCTFail("OAuth service should not make a call when the cloud host is not set")
        }

        let rsp = oauthService.getToken(clientID: "client ID", secret: "client secret")
        try mockStream.sendMessage(Sensory_Api_Common_TokenResponse())

        rsp.whenSuccess { _ in
            XCTFail("Call should fail when the cloud host is not set")
        }
        rsp.whenFailure { [weak self] _ in
            self?.expectResponse.fulfill()
        }

        wait(for: [expectResponse], timeout: 1)
    }

    func testGetClient() throws {
        let oauthService = OAuthService()
        _ = try oauthService.getClient(host: CloudHost(host: "mockHost", port: 443, isSecure: true))
    }
}

/// A "mock" for OAuth service that allows for injecting a mock client without overwriting any other behavior
class OAuthServiceMockClient: OAuthService {

    var mockClient: Sensory_Api_Oauth_OauthServiceTestClient

    init(client: Sensory_Api_Oauth_OauthServiceTestClient) {
        self.mockClient = client
    }

    override func getClient(host: CloudHost) throws -> Sensory_Api_Oauth_OauthServiceClientProtocol {
        return mockClient
    }
}
