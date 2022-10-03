//
//  VideoServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/11/21.
//

import XCTest
@testable import SensoryCloud
import GRPC
import NIOCore
import NIOPosix

final class VideoServiceTests: XCTestCase {
    static var group: EventLoopGroup!
    static var server: Server!
    static var mockCredentialProvider: MockCredentialProvider!
    static var mockToken = "Mock Access Token"

    static var expectResponse = XCTestExpectation(description: "grpc response should be received")
    static var expectRequest = XCTestExpectation(description: "grpc request should be sent")

    // Get Models
    static var expectedGetModelsResponse: Sensory_Api_V1_Video_GetModelsResponse {
        var model = Sensory_Api_V1_Video_VideoModel()
        model.modelType = .faceBiometric
        model.name = "Video Model"
        model.isEnrollable = true
        model.technology = .ts
        var rsp = Sensory_Api_V1_Video_GetModelsResponse()
        rsp.models = [model]
        return rsp
    }

    // CreateEnrollment
    static var expectedCreateEnrollmentResponse: Sensory_Api_V1_Video_CreateEnrollmentResponse {
        var rsp = Sensory_Api_V1_Video_CreateEnrollmentResponse()
        rsp.percentComplete = 25
        rsp.isAlive = true
        rsp.modelName = "Some Model"
        return rsp
    }
    static var expectedCreateEnrollmentRequest: Sensory_Api_V1_Video_CreateEnrollmentRequest {
        var config = Sensory_Api_V1_Video_CreateEnrollmentConfig()
        config.modelName = "Some Model"
        config.userID = "User ID"
        config.deviceID = "Device ID"
        config.description_p = "Video Enrollment"
        config.isLivenessEnabled = true
        config.livenessThreshold = .highest
        config.numLivenessFramesRequired = 3
        var req = Sensory_Api_V1_Video_CreateEnrollmentRequest()
        req.config = config
        return req
    }

    // Authenticate
    static var expectedAuthResponse: Sensory_Api_V1_Video_AuthenticateResponse {
        var rsp = Sensory_Api_V1_Video_AuthenticateResponse()
        rsp.score = 0
        rsp.success = true
        rsp.isAlive = false
        return rsp
    }
    static var expectedAuthRequest: Sensory_Api_V1_Video_AuthenticateRequest {
        var config = Sensory_Api_V1_Video_AuthenticateConfig()
        config.enrollmentID = "Enrollment"
        config.isLivenessEnabled = true
        config.livenessThreshold = .low
        var req = Sensory_Api_V1_Video_AuthenticateRequest()
        req.config = config
        return req
    }

    // Liveness
    static var expectedLivenessResponse: Sensory_Api_V1_Video_LivenessRecognitionResponse {
        var rsp = Sensory_Api_V1_Video_LivenessRecognitionResponse()
        rsp.isAlive = true
        rsp.score = 25
        return rsp
    }
    static var expectedLivenessRequest: Sensory_Api_V1_Video_ValidateRecognitionRequest {
        var config = Sensory_Api_V1_Video_ValidateRecognitionConfig()
        config.modelName = "Liveness Model"
        config.userID = "User"
        config.threshold = .medium
        var req = Sensory_Api_V1_Video_ValidateRecognitionRequest()
        req.config = config
        return req
    }

    override class func setUp() {
        super.setUp()

        mockCredentialProvider = MockCredentialProvider()
        mockCredentialProvider.accessToken = mockToken
        Service.shared.credentialProvider = mockCredentialProvider

        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        server = try! Server.insecure(group: group)
            .withServiceProviders([VideoModelsProvider(), VideoBiometricsProvider(), VideoRecognitionProvider()])
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
        resetExpectations()
    }

    func resetExpectations() {
        VideoServiceTests.expectResponse = XCTestExpectation(description: "grpc response should be received")
        VideoServiceTests.expectRequest = XCTestExpectation(description: "grpc request should be sent")
    }

    func testGetModels() throws {
        let videoService = VideoService()

        let rsp = videoService.getModels()
        rsp.whenSuccess { models in
            XCTAssertEqual(VideoServiceTests.expectedGetModelsResponse, models)
            VideoServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [VideoServiceTests.expectResponse, VideoServiceTests.expectRequest], timeout: 1)
    }

    func testCreateEnrollment() throws {
        let videoService = VideoService()
        Config.deviceID = "Device ID"

        let stream = try videoService.createEnrollment(
            modelName: "Some Model",
            userID: "User ID",
            description: "Video Enrollment",
            isLivenessEnabled: true,
            livenessThreshold: .highest,
            numLiveFramesRequired: 3
        ) { response in
            XCTAssertEqual(VideoServiceTests.expectedCreateEnrollmentResponse, response)
            VideoServiceTests.expectResponse.fulfill()
        }

        wait(for: [VideoServiceTests.expectResponse, VideoServiceTests.expectRequest], timeout: 1)
        XCTAssertNoThrow(try stream.sendEnd().wait())
    }

    func testAuthenticate() throws {
        let videoService = VideoService()

        let stream = try videoService.authenticate(
            enrollment: .enrollmentID("Enrollment"),
            isLivenessEnabled: true,
            livenessThreshold: .low
        ) { response in
            XCTAssertEqual(VideoServiceTests.expectedAuthResponse, response)
            VideoServiceTests.expectResponse.fulfill()
        }

        wait(for: [VideoServiceTests.expectResponse, VideoServiceTests.expectRequest], timeout: 1)
        XCTAssertNoThrow(try stream.sendEnd().wait())
    }

    func testValidateLiveness() throws {
        let videoService = VideoService()

        let stream = try videoService.validateLiveness(
            modelName: "Liveness Model",
            userID: "User",
            threshold: .medium
        ) { response in
            XCTAssertEqual(VideoServiceTests.expectedLivenessResponse, response)
            VideoServiceTests.expectResponse.fulfill()
        }

        wait(for: [VideoServiceTests.expectResponse, VideoServiceTests.expectRequest], timeout: 1)
        XCTAssertNoThrow(try stream.sendEnd().wait())
    }
}

final class VideoModelsProvider: Sensory_Api_V1_Video_VideoModelsProvider {
    var interceptors: SensoryCloud.Sensory_Api_V1_Video_VideoModelsServerInterceptorFactoryProtocol? = nil

    func getModels(
        request: SensoryCloud.Sensory_Api_V1_Video_GetModelsRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Video_GetModelsResponse>
    {
        assertRequestMetadata(context: context, accessToken: VideoServiceTests.mockToken)
        XCTAssertEqual(Sensory_Api_V1_Video_GetModelsRequest(), request)
        VideoServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(VideoServiceTests.expectedGetModelsResponse)
    }
}

final class VideoBiometricsProvider: Sensory_Api_V1_Video_VideoBiometricsProvider {
    var interceptors: SensoryCloud.Sensory_Api_V1_Video_VideoBiometricsServerInterceptorFactoryProtocol? = nil

    func createEnrollment(
        context: GRPC.StreamingResponseCallContext<SensoryCloud.Sensory_Api_V1_Video_CreateEnrollmentResponse>
    ) -> NIOCore.EventLoopFuture<(GRPC.StreamEvent<SensoryCloud.Sensory_Api_V1_Video_CreateEnrollmentRequest>) -> Void>
    {
        func handle(_ event: StreamEvent<SensoryCloud.Sensory_Api_V1_Video_CreateEnrollmentRequest>) {
            switch event {
            case .message(let request):
                XCTAssertEqual(VideoServiceTests.expectedCreateEnrollmentRequest, request)
                VideoServiceTests.expectRequest.fulfill()
            case .end:
                context.statusPromise.succeed(.ok)
            }
        }

        assertRequestMetadata(context: context, accessToken: VideoServiceTests.mockToken)
        _ = context.sendResponse(VideoServiceTests.expectedCreateEnrollmentResponse)
        return context.eventLoop.makeSucceededFuture(handle(_:))
    }

    func authenticate(
        context: GRPC.StreamingResponseCallContext<SensoryCloud.Sensory_Api_V1_Video_AuthenticateResponse>) -> NIOCore.EventLoopFuture<(GRPC.StreamEvent<SensoryCloud.Sensory_Api_V1_Video_AuthenticateRequest>) -> Void>
    {
        func handle(_ event: StreamEvent<SensoryCloud.Sensory_Api_V1_Video_AuthenticateRequest>) {
            switch event {
            case .message(let request):
                XCTAssertEqual(VideoServiceTests.expectedAuthRequest, request)
                VideoServiceTests.expectRequest.fulfill()
            case .end:
                context.statusPromise.succeed(.ok)
            }
        }

        assertRequestMetadata(context: context, accessToken: VideoServiceTests.mockToken)
        _ = context.sendResponse(VideoServiceTests.expectedAuthResponse)
        return context.eventLoop.makeSucceededFuture(handle(_:))
    }
}

final class VideoRecognitionProvider: Sensory_Api_V1_Video_VideoRecognitionProvider {
    var interceptors: SensoryCloud.Sensory_Api_V1_Video_VideoRecognitionServerInterceptorFactoryProtocol? = nil

    func validateLiveness(
        context: GRPC.StreamingResponseCallContext<SensoryCloud.Sensory_Api_V1_Video_LivenessRecognitionResponse>) -> NIOCore.EventLoopFuture<(GRPC.StreamEvent<SensoryCloud.Sensory_Api_V1_Video_ValidateRecognitionRequest>) -> Void>
    {
        func handle(_ event: StreamEvent<SensoryCloud.Sensory_Api_V1_Video_ValidateRecognitionRequest>) {
            switch event {
            case .message(let request):
                XCTAssertEqual(VideoServiceTests.expectedLivenessRequest, request)
                VideoServiceTests.expectRequest.fulfill()
            case .end:
                context.statusPromise.succeed(.ok)
            }
        }

        assertRequestMetadata(context: context, accessToken: VideoServiceTests.mockToken)
        _ = context.sendResponse(VideoServiceTests.expectedLivenessResponse)
        return context.eventLoop.makeSucceededFuture(handle(_:))
    }
}
