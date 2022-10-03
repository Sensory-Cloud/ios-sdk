//
//  OAuthServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/12/21.
//

import XCTest
@testable import SensoryCloud
import GRPC
import NIOCore
import NIOPosix

final class OAuthServiceTests: XCTestCase {
    static var group: EventLoopGroup!
    static var server: Server!

    static var expectResponse = XCTestExpectation(description: "grpc response should be received")
    static var expectRequest = XCTestExpectation(description: "grpc request should be sent")

    // Device Enrollment
    static var expectedEnrollDeviceResponse: Sensory_Api_V1_Management_DeviceResponse {
        var rsp = Sensory_Api_V1_Management_DeviceResponse()
        rsp.deviceID = "Device ID"
        rsp.name = "Device Name"
        return rsp
    }
    static var expectedEnrollDeviceRequest: Sensory_Api_V1_Management_EnrollDeviceRequest {
        var client = Sensory_Api_Common_GenericClient()
        client.clientID = "Client ID"
        client.secret = "Client Secret"
        var req = Sensory_Api_V1_Management_EnrollDeviceRequest()
        req.client = client
        req.name = "Device Name"
        req.deviceID = "Device ID"
        req.tenantID = "Tenant ID"
        req.credential = "Credential"
        return req
    }

    // Get Token
    static var expectedGetTokenResponse: Sensory_Api_Common_TokenResponse {
        var rsp = Sensory_Api_Common_TokenResponse()
        rsp.accessToken = "Mock Access Token"
        rsp.expiresIn = 500
        rsp.tokenType = "Bearer"
        rsp.keyID = "Key ID"
        return rsp
    }
    static var expectedGetTokenRequest: Sensory_Api_Oauth_TokenRequest {
        var req = Sensory_Api_Oauth_TokenRequest()
        req.clientID = "client ID"
        req.secret = "client secret"
        return req
    }

    // Renew Token
    static var expectedRenewDeviceResponse: Sensory_Api_V1_Management_DeviceResponse {
        var rsp = Sensory_Api_V1_Management_DeviceResponse()
        rsp.deviceID = "Device ID"
        rsp.name = "Device Name"
        return rsp
    }
    static var expectedRenewDeviceRequest: Sensory_Api_V1_Management_RenewDeviceCredentialRequest {
        var req = Sensory_Api_V1_Management_RenewDeviceCredentialRequest()
        req.deviceID = "Device ID"
        req.clientID = "Client ID"
        req.tenantID = "Tenant ID"
        req.credential = "credential"
        return req
    }

    override class func setUp() {
        super.setUp()

        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        server = try! Server.insecure(group: group)
            .withServiceProviders([OAuthServiceProvider(), DeviceServiceProvider()])
            .bind(host: "localhost", port: 0)
            .wait()
        Config.setCloudHost(host: "localhost", port: server.channel.localAddress!.port!, isSecure: false)
    }

    override class func tearDown() {
        XCTAssertNoThrow(try self.server.initiateGracefulShutdown().wait())
        XCTAssertNoThrow(try self.group.syncShutdownGracefully())
        super.tearDown()
    }

    override func setUp() {
        super.setUp()
        resetExpectation()
    }

    func resetExpectation() {
        OAuthServiceTests.expectResponse = XCTestExpectation(description: "grpc response should be received")
        OAuthServiceTests.expectRequest = XCTestExpectation(description: "grpc request should be sent")
    }

    func testEnrollDevice() throws {
        let oauthService = OAuthService()
        Config.deviceID = "Device ID"
        Config.tenantID = "Tenant ID"

        let rsp = oauthService.enrollDevice(
            name: "Device Name",
            credential: "Credential",
            clientID: "Client ID",
            clientSecret: "Client Secret"
        )
        rsp.whenSuccess { enrollments in
            XCTAssertEqual(OAuthServiceTests.expectedEnrollDeviceResponse, enrollments)
            OAuthServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [OAuthServiceTests.expectResponse, OAuthServiceTests.expectRequest], timeout: 1)
    }

    func testGetToken() throws {
        let oauthService = OAuthService()

        let rsp = oauthService.getToken(clientID: "client ID", secret: "client secret")
        rsp.whenSuccess { enrollments in
            XCTAssertEqual(OAuthServiceTests.expectedGetTokenResponse, enrollments)
            OAuthServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [OAuthServiceTests.expectResponse, OAuthServiceTests.expectRequest], timeout: 1)
    }

    func testGetTokenMissingHost() throws {
        let oauthService = OAuthService()

        let existingHost = Config.getCloudHost()
        Config.cloudHost = nil
        defer {
            if let host = existingHost {
                Config.setCloudHost(host: host.host, port: host.port, isSecure: host.isSecure)
            }
        }

        let rsp = oauthService.getToken(clientID: "client ID", secret: "client secret")
        rsp.whenSuccess { _ in
            XCTFail("Call should fail when the cloud host is not set")
        }
        rsp.whenFailure { _ in
            OAuthServiceTests.expectResponse.fulfill()
        }

        wait(for: [OAuthServiceTests.expectResponse], timeout: 1)
    }

    func testGetClient() throws {
        let oauthService = OAuthService()
        _ = try oauthService.getOAuthClient(host: CloudHost("mockHost", 443, true))
    }

    func testRenewDeviceCredential() throws {
        let oauthService = OAuthService()
        Config.deviceID = "Device ID"
        Config.tenantID = "Tenant ID"

        let rsp = oauthService.renewDeviceCredential(clientID: "Client ID", credential: "credential")
        rsp.whenSuccess { response in
            XCTAssertEqual(OAuthServiceTests.expectedRenewDeviceResponse, response)
            OAuthServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [OAuthServiceTests.expectResponse, OAuthServiceTests.expectRequest], timeout: 1)
    }
}

final class OAuthServiceProvider: Sensory_Api_Oauth_OauthServiceProvider {
    var interceptors: SensoryCloud.Sensory_Api_Oauth_OauthServiceServerInterceptorFactoryProtocol? = nil

    func getToken(
        request: SensoryCloud.Sensory_Api_Oauth_TokenRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_Common_TokenResponse>
    {
        assertRequestMetadata(context: context)
        XCTAssertEqual(OAuthServiceTests.expectedGetTokenRequest, request)
        OAuthServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(OAuthServiceTests.expectedGetTokenResponse)
    }

    func signToken(
        request: SensoryCloud.Sensory_Api_Oauth_SignTokenRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_Common_TokenResponse>
    {
        return context.eventLoop.makeSucceededFuture(Sensory_Api_Common_TokenResponse())
    }

    func getWhoAmI(
        request: SensoryCloud.Sensory_Api_Oauth_WhoAmIRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_Oauth_WhoAmIResponse>
    {
        return context.eventLoop.makeSucceededFuture(Sensory_Api_Oauth_WhoAmIResponse())
    }

    func getPublicKey(
        request: SensoryCloud.Sensory_Api_Oauth_PublicKeyRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_Oauth_PublicKeyResponse>
    {
        return context.eventLoop.makeSucceededFuture(Sensory_Api_Oauth_PublicKeyResponse())
    }
}

final class DeviceServiceProvider: Sensory_Api_V1_Management_DeviceServiceProvider {
    var interceptors: SensoryCloud.Sensory_Api_V1_Management_DeviceServiceServerInterceptorFactoryProtocol? = nil

    func enrollDevice(
        request: SensoryCloud.Sensory_Api_V1_Management_EnrollDeviceRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_DeviceResponse>
    {
        assertRequestMetadata(context: context)
        XCTAssertEqual(OAuthServiceTests.expectedEnrollDeviceRequest, request)
        OAuthServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(OAuthServiceTests.expectedEnrollDeviceResponse)
    }

    func renewDeviceCredential(
        request: SensoryCloud.Sensory_Api_V1_Management_RenewDeviceCredentialRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_DeviceResponse>
    {
        assertRequestMetadata(context: context)
        XCTAssertEqual(OAuthServiceTests.expectedRenewDeviceRequest, request)
        OAuthServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(OAuthServiceTests.expectedRenewDeviceResponse)
    }

    // Unused
    func getWhoAmI(request: SensoryCloud.Sensory_Api_V1_Management_DeviceGetWhoAmIRequest, context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_DeviceResponse> {
        return context.eventLoop.makeFailedFuture(NetworkError.notInitialized)
    }

    func getDevice(request: SensoryCloud.Sensory_Api_V1_Management_DeviceRequest, context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_GetDeviceResponse> {
        return context.eventLoop.makeFailedFuture(NetworkError.notInitialized)
    }

    func getDevices(request: SensoryCloud.Sensory_Api_V1_Management_GetDevicesRequest, context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_DeviceListResponse> {
        return context.eventLoop.makeFailedFuture(NetworkError.notInitialized)
    }

    func updateDevice(request: SensoryCloud.Sensory_Api_V1_Management_UpdateDeviceRequest, context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_DeviceResponse> {
        return context.eventLoop.makeFailedFuture(NetworkError.notInitialized)
    }

    func deleteDevice(request: SensoryCloud.Sensory_Api_V1_Management_DeviceRequest, context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_DeviceResponse> {
        return context.eventLoop.makeFailedFuture(NetworkError.notInitialized)
    }
}
