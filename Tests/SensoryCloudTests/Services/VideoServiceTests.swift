//
//  VideoServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/11/21.
//

import XCTest
@testable import SensoryCloud

final class VideoServiceTests: XCTestCase {

    var mockService = MockService()
    var expectResponse = XCTestExpectation(description: "grpc response should be received")
    var expectRequestMetadata = XCTestExpectation(description: "request metadata should be sent")
    var expectRequest = XCTestExpectation(description: "grpc request should be sent")

    override func setUp() {
        resetExpectations()
        mockService.reset()
        Config.deviceID = nil
    }

    func resetExpectations() {
        expectResponse = XCTestExpectation(description: "grpc response should be received")
        expectRequestMetadata = XCTestExpectation(description: "request metadata should be sent")
        expectRequest = XCTestExpectation(description: "grpc request should be sent")
    }

    func testGetModels() throws {
        let mockClient = Sensory_Api_V1_Video_VideoModelsTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Video_VideoModelsClientProtocol.self, client: mockClient)
        let videoService = VideoService(service: mockService)

        var videoModel = Sensory_Api_V1_Video_VideoModel()
        videoModel.modelType = .faceBiometric
        videoModel.name = "Video Model"
        videoModel.isEnrollable = true
        videoModel.technology = .ts
        var expectedResponse = Sensory_Api_V1_Video_GetModelsResponse()
        expectedResponse.models = [videoModel]

        let mockStream = mockClient.makeGetModelsResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultUnaryHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(Sensory_Api_V1_Video_GetModelsRequest(), message)
                self?.expectRequest.fulfill()
            case .end:
                break
            }
        }

        let rsp = videoService.getModels()
        try mockStream.sendMessage(expectedResponse)
        rsp.whenSuccess { [weak self] models in
            XCTAssertEqual(expectedResponse, models)
            self?.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testCreateEnrollment() throws {
        let mockClient = Sensory_Api_V1_Video_VideoBiometricsTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Video_VideoBiometricsClientProtocol.self, client: mockClient)
        let videoService = VideoService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Video_CreateEnrollmentResponse()
        expectedResponse.percentComplete = 25
        expectedResponse.isAlive = true
        expectedResponse.modelName = "Some Model"

        Config.deviceID = "Device ID"
        var enrollmentConfig = Sensory_Api_V1_Video_CreateEnrollmentConfig()
        enrollmentConfig.modelName = "Some Model"
        enrollmentConfig.userID = "User ID"
        enrollmentConfig.deviceID = "Device ID"
        enrollmentConfig.description_p = "Video Enrollment"
        enrollmentConfig.isLivenessEnabled = true
        enrollmentConfig.livenessThreshold = .highest
        var expectedRequest = Sensory_Api_V1_Video_CreateEnrollmentRequest()
        expectedRequest.config = enrollmentConfig

        let mockStream = mockClient.makeCreateEnrollmentResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultStreamHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                XCTFail("VideoService should not directly end the stream")
            }
        }

        _ = try videoService.createEnrollment(
            modelName: "Some Model",
            userID: "User ID",
            description: "Video Enrollment",
            isLivenessEnabled: true,
            livenessThreshold: .highest
        ) { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        try mockStream.sendMessage(expectedResponse)

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testAuthenticate() throws {
        let mockClient = Sensory_Api_V1_Video_VideoBiometricsTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Video_VideoBiometricsClientProtocol.self, client: mockClient)
        let videoService = VideoService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Video_AuthenticateResponse()
        expectedResponse.score = 0
        expectedResponse.success = true
        expectedResponse.isAlive = false

        var authConfig = Sensory_Api_V1_Video_AuthenticateConfig()
        authConfig.enrollmentID = "Enrollment"
        authConfig.isLivenessEnabled = true
        authConfig.livenessThreshold = .low
        var expectedRequest = Sensory_Api_V1_Video_AuthenticateRequest()
        expectedRequest.config = authConfig

        let mockStream = mockClient.makeAuthenticateResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultStreamHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                XCTFail("AudioService should not directly end the stream")
            }
        }

        _ = try videoService.authenticate(
            enrollmentID: "Enrollment",
            isLivenessEnabled: true,
            livenessThreshold: .low
        ) { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        try mockStream.sendMessage(expectedResponse)

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testValidateLiveness() throws {
        let mockClient = Sensory_Api_V1_Video_VideoRecognitionTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Video_VideoRecognitionClientProtocol.self, client: mockClient)
        let videoService = VideoService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Video_LivenessRecognitionResponse()
        expectedResponse.isAlive = true
        expectedResponse.score = 25

        var livenessConfig = Sensory_Api_V1_Video_ValidateRecognitionConfig()
        livenessConfig.modelName = "Liveness Model"
        livenessConfig.userID = "User"
        livenessConfig.threshold = .medium
        var expectedRequest = Sensory_Api_V1_Video_ValidateRecognitionRequest()
        expectedRequest.config = livenessConfig

        let mockStream = mockClient.makeValidateLivenessResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultStreamHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                XCTFail("AudioService should not directly end the stream")
            }
        }

        _ = try videoService.validateLiveness(
            modelName: "Liveness Model",
            userID: "User",
            threshold: .medium
        ) { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        try mockStream.sendMessage(expectedResponse)

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }
}
