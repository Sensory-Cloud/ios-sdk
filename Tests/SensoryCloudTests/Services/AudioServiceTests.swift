//
//  AudioServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/10/21.
//

import XCTest
@testable import SensoryCloud
import CoreMedia
import GRPC
import NIOCore
import NIOPosix

final class AudioServiceTests: XCTestCase {
    static var group: EventLoopGroup!
    static var server: Server!
    static var mockCredentialProvider: MockCredentialProvider!
    static var mockToken = "Mock Acces Token"

    static var expectResponse = XCTestExpectation(description: "grpc response should be received")
    static var expectRequest = XCTestExpectation(description: "grpc request should be sent")

    // Audio Config
    static var mockAudioConfig: Sensory_Api_V1_Audio_AudioConfig {
        var config = Sensory_Api_V1_Audio_AudioConfig()
        config.encoding = .linear16
        config.sampleRateHertz = 16000
        config.audioChannelCount = 1
        config.languageCode = Config.languageCode
        return config
    }

    // Get Models
    static var expectedGetModelsResponse: Sensory_Api_V1_Audio_GetModelsResponse {
        var model = Sensory_Api_V1_Audio_AudioModel()
        model.fixedPhrase = "phrase"
        model.modelType = .soundEventEnrollable
        model.name = "mock model"
        var rsp = Sensory_Api_V1_Audio_GetModelsResponse()
        rsp.models = [model]
        return rsp
    }

    // Create Enrollment
    static var expectedCreateEnrollmentResponse: Sensory_Api_V1_Audio_CreateEnrollmentResponse {
        var rsp = Sensory_Api_V1_Audio_CreateEnrollmentResponse()
        rsp.audioEnergy = 0.5
        rsp.percentComplete = 25
        return rsp
    }
    static var expectedCreateEnrollmentRequest: Sensory_Api_V1_Audio_CreateEnrollmentRequest {
        var config = Sensory_Api_V1_Audio_CreateEnrollmentConfig()
        config.audio = mockAudioConfig
        config.modelName = "Mock Model Name"
        config.userID = "Mock User ID"
        config.deviceID = "Mock Device ID"
        config.description_p = "Mock Description"
        config.isLivenessEnabled = true
        config.enrollmentNumUtterances = 5
        var req = Sensory_Api_V1_Audio_CreateEnrollmentRequest()
        req.config = config
        return req
    }

    // Authenticate
    static var expectedAuthResponse: Sensory_Api_V1_Audio_AuthenticateResponse {
        var rsp = Sensory_Api_V1_Audio_AuthenticateResponse()
        rsp.audioEnergy = 0.5
        return rsp
    }
    static var expectedAuthRequest: Sensory_Api_V1_Audio_AuthenticateRequest {
        var config = Sensory_Api_V1_Audio_AuthenticateConfig()
        config.audio = mockAudioConfig
        config.enrollmentID = "Mock Enrollment"
        config.isLivenessEnabled = false
        var req = Sensory_Api_V1_Audio_AuthenticateRequest()
        req.config = config
        return req
    }

    // Validate Trigger
    static var expectedValidateResponse: Sensory_Api_V1_Audio_ValidateEventResponse {
        var rsp = Sensory_Api_V1_Audio_ValidateEventResponse()
        rsp.audioEnergy = 0.25
        rsp.success = true
        rsp.resultID = "result"
        rsp.score = 99
        return rsp
    }
    static var expectedValidateRequest: Sensory_Api_V1_Audio_ValidateEventRequest {
        var config = Sensory_Api_V1_Audio_ValidateEventConfig()
        config.audio = mockAudioConfig
        config.modelName = "Trigger Model"
        config.userID = "Some User"
        config.sensitivity = .medium
        var req = Sensory_Api_V1_Audio_ValidateEventRequest()
        req.config = config
        return req
    }

    // Enrolled Event
    static var expectedEnrollEventResponse: Sensory_Api_V1_Audio_CreateEnrollmentResponse {
        var rsp = Sensory_Api_V1_Audio_CreateEnrollmentResponse()
        rsp.audioEnergy = 0.5
        rsp.percentComplete = 25
        return rsp
    }
    static var expectedEnrollEventRequest: Sensory_Api_V1_Audio_CreateEnrolledEventRequest {
        var config = Sensory_Api_V1_Audio_CreateEnrollmentEventConfig()
        config.audio = mockAudioConfig
        config.modelName = "Mock Model Name"
        config.userID = "Mock User ID"
        config.description_p = "Mock Description"
        var req = Sensory_Api_V1_Audio_CreateEnrolledEventRequest()
        req.config = config
        return req
    }

    // Validate Enrolled Event
    static var expectedValidateEnrolledEventResponse: Sensory_Api_V1_Audio_ValidateEnrolledEventResponse {
        var rsp = Sensory_Api_V1_Audio_ValidateEnrolledEventResponse()
        rsp.audioEnergy = 0.5
        return rsp
    }
    static var expectedValidateEnrolledEventRequest: Sensory_Api_V1_Audio_ValidateEnrolledEventRequest {
        var config = Sensory_Api_V1_Audio_ValidateEnrolledEventConfig()
        config.audio = mockAudioConfig
        config.enrollmentID = "Mock Enrollment"
        config.sensitivity = .highest
        var req = Sensory_Api_V1_Audio_ValidateEnrolledEventRequest()
        req.config = config
        return req
    }

    // Transcription
    static var expectedTranscribeResponse: Sensory_Api_V1_Audio_TranscribeResponse {
        var rsp = Sensory_Api_V1_Audio_TranscribeResponse()
        rsp.audioEnergy = 0.25
        rsp.transcript = "Some Transcription"
        return rsp
    }
    static var expectedTranscribeRequest: Sensory_Api_V1_Audio_TranscribeRequest {
        var config = Sensory_Api_V1_Audio_TranscribeConfig()
        config.audio = mockAudioConfig
        config.modelName = "Transcript Model"
        config.userID = "Some User"
        config.vadSensitivity = .low
        config.vadDuration = 1
        var req = Sensory_Api_V1_Audio_TranscribeRequest()
        req.config = config
        return req
    }

    // Voice Synthesis
    static var expectedSynthesisResponse: Sensory_Api_V1_Audio_SynthesizeSpeechResponse {
        var rsp = Sensory_Api_V1_Audio_SynthesizeSpeechResponse()
        rsp.config = mockAudioConfig
        rsp.audioContent = Data(repeating: 10, count: 20)
        return rsp
    }
    static var expectedSynthesisRequest: Sensory_Api_V1_Audio_SynthesizeSpeechRequest {
        var config = Sensory_Api_V1_Audio_VoiceSynthesisConfig()
        config.voice = "Mock Voice"
        config.audio = mockAudioConfig
        var req = Sensory_Api_V1_Audio_SynthesizeSpeechRequest()
        req.config = config
        req.phrase = "Mock Phrase"
        return req
    }

    override class func setUp() {
        super.setUp()

        mockCredentialProvider = MockCredentialProvider()
        mockCredentialProvider.accessToken = mockToken
        Service.shared.credentialProvider = mockCredentialProvider

        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        server = try! Server.insecure(group: group)
            .withServiceProviders([
                AudioModelsProvider(),
                AudioBiometricsProvider(),
                AudioEventsProvider(),
                AudioTranscriptionsProvider(),
                AudioSynthesisProvider()
            ])
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
        AudioServiceTests.expectResponse = XCTestExpectation(description: "grpc response should be received")
        AudioServiceTests.expectRequest = XCTestExpectation(description: "grpc request should be sent")
    }

    func testGetAudioModels() throws {
        let audioService = AudioService()

        let rsp = audioService.getModels()
        rsp.whenSuccess { models in
            XCTAssertEqual(AudioServiceTests.expectedGetModelsResponse, models)
            AudioServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [AudioServiceTests.expectResponse, AudioServiceTests.expectRequest], timeout: 1)
    }

    func testCreateEnrollment() throws {
        let audioService = AudioService()
        Config.deviceID = "Mock Device ID"

        let stream = try audioService.createEnrollment(
            modelName: "Mock Model Name",
            userID: "Mock User ID",
            description: "Mock Description",
            isLivenessEnabled: true,
            numUtterances: 5,
            enrollmentDuration: 10 // Should be ignored since numUtterances is also specified
        ) { response in
            XCTAssertEqual(AudioServiceTests.expectedCreateEnrollmentResponse, response)
            AudioServiceTests.expectResponse.fulfill()
        }

        wait(for: [AudioServiceTests.expectResponse, AudioServiceTests.expectRequest], timeout: 1)
        XCTAssertNoThrow(try stream.sendEnd().wait())
    }

    func testAuthenticateEnrollment() throws {
        let audioService = AudioService()

        let stream = try audioService.authenticate(
            enrollment: .enrollmentID("Mock Enrollment"),
            isLivenessEnabled: false
        ) { response in
            XCTAssertEqual(AudioServiceTests.expectedAuthResponse, response)
            AudioServiceTests.expectResponse.fulfill()
        }

        wait(for: [AudioServiceTests.expectResponse, AudioServiceTests.expectRequest], timeout: 1)
        XCTAssertNoThrow(try stream.sendEnd().wait())
    }

    func testValidateTrigger() throws {
        let audioService = AudioService()

        let stream = try audioService.validateTrigger(
            modelName: "Trigger Model",
            userID: "Some User",
            sensitivity: .medium
        ) { response in
            XCTAssertEqual(AudioServiceTests.expectedValidateResponse, response)
            AudioServiceTests.expectResponse.fulfill()
        }

        wait(for: [AudioServiceTests.expectResponse, AudioServiceTests.expectRequest], timeout: 1)
        XCTAssertNoThrow(try stream.sendEnd().wait())
    }

    func testCreateEnrolledEvent() throws {
        let audioService = AudioService()
        Config.deviceID = "Mock Device ID"

        let stream = try audioService.streamCreateEnrolledEvent(
            modelName: "Mock Model Name",
            userID: "Mock User ID",
            description: "Mock Description"
        ) { response in
            XCTAssertEqual(AudioServiceTests.expectedEnrollEventResponse, response)
            AudioServiceTests.expectResponse.fulfill()
        }

        wait(for: [AudioServiceTests.expectResponse, AudioServiceTests.expectRequest], timeout: 1)
        XCTAssertNoThrow(try stream.sendEnd().wait())
    }

    func testValidateEnrolledEvent() throws {
        let audioService = AudioService()

        let stream = try audioService.streamValidateEnrolledEvent(
            enrollment: .enrollmentID("Mock Enrollment"),
            sensitivity: .highest
        ) { response in
            XCTAssertEqual(AudioServiceTests.expectedValidateEnrolledEventResponse, response)
            AudioServiceTests.expectResponse.fulfill()
        }

        wait(for: [AudioServiceTests.expectResponse, AudioServiceTests.expectRequest], timeout: 1)
        XCTAssertNoThrow(try stream.sendEnd().wait())
    }

    func testTranscribeAudio() throws {
        let audioService = AudioService()

        let stream = try audioService.transcribeAudio(
            modelName: "Transcript Model",
            userID: "Some User"
        ) { response in
            XCTAssertEqual(AudioServiceTests.expectedTranscribeResponse, response)
            AudioServiceTests.expectResponse.fulfill()
        }

        wait(for: [AudioServiceTests.expectResponse, AudioServiceTests.expectRequest], timeout: 1)
        XCTAssertNoThrow(try stream.sendEnd().wait())
    }

    func testSynthesizeSpeech() throws {
        let audioService = AudioService()

        _ = try audioService.synthesizeSpeech(
            phrase: "Mock Phrase",
            voiceName: "Mock Voice"
        ) { response in
            XCTAssertEqual(AudioServiceTests.expectedSynthesisResponse, response)
            AudioServiceTests.expectResponse.fulfill()
        }

        wait(for: [AudioServiceTests.expectResponse, AudioServiceTests.expectRequest], timeout: 1)
    }
}

final class AudioModelsProvider: Sensory_Api_V1_Audio_AudioModelsProvider {
    var interceptors: SensoryCloud.Sensory_Api_V1_Audio_AudioModelsServerInterceptorFactoryProtocol? = nil

    func getModels(
        request: SensoryCloud.Sensory_Api_V1_Audio_GetModelsRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Audio_GetModelsResponse>
    {
        assertRequestMetadata(context: context, accessToken: AudioServiceTests.mockToken)
        XCTAssertEqual(Sensory_Api_V1_Audio_GetModelsRequest(), request)
        AudioServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(AudioServiceTests.expectedGetModelsResponse)
    }
}

final class AudioBiometricsProvider: Sensory_Api_V1_Audio_AudioBiometricsProvider {
    var interceptors: SensoryCloud.Sensory_Api_V1_Audio_AudioBiometricsServerInterceptorFactoryProtocol? = nil

    func createEnrollment(
        context: GRPC.StreamingResponseCallContext<SensoryCloud.Sensory_Api_V1_Audio_CreateEnrollmentResponse>) -> NIOCore.EventLoopFuture<(GRPC.StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_CreateEnrollmentRequest>) -> Void>
    {
        func handle(_ event: StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_CreateEnrollmentRequest>) {
            switch event {
            case .message(let request):
                XCTAssertEqual(AudioServiceTests.expectedCreateEnrollmentRequest, request)
                AudioServiceTests.expectRequest.fulfill()
            case .end:
                context.statusPromise.succeed(.ok)
            }
        }

        assertRequestMetadata(context: context, accessToken: AudioServiceTests.mockToken)
        _ = context.sendResponse(AudioServiceTests.expectedCreateEnrollmentResponse)
        return context.eventLoop.makeSucceededFuture(handle(_:))
    }

    func authenticate(
        context: GRPC.StreamingResponseCallContext<SensoryCloud.Sensory_Api_V1_Audio_AuthenticateResponse>) -> NIOCore.EventLoopFuture<(GRPC.StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_AuthenticateRequest>) -> Void>
    {
        func handle(_ event: StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_AuthenticateRequest>) {
            switch event {
            case .message(let request):
                XCTAssertEqual(AudioServiceTests.expectedAuthRequest, request)
                AudioServiceTests.expectRequest.fulfill()
            case .end:
                context.statusPromise.succeed(.ok)
            }
        }

        assertRequestMetadata(context: context, accessToken: AudioServiceTests.mockToken)
        _ = context.sendResponse(AudioServiceTests.expectedAuthResponse)
        return context.eventLoop.makeSucceededFuture(handle(_:))
    }
}

final class AudioEventsProvider: Sensory_Api_V1_Audio_AudioEventsProvider {
    var interceptors: SensoryCloud.Sensory_Api_V1_Audio_AudioEventsServerInterceptorFactoryProtocol? = nil

    func validateEvent(
        context: GRPC.StreamingResponseCallContext<SensoryCloud.Sensory_Api_V1_Audio_ValidateEventResponse>) -> NIOCore.EventLoopFuture<(GRPC.StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_ValidateEventRequest>) -> Void>
    {
        func handle(_ event: StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_ValidateEventRequest>) {
            switch event {
            case .message(let request):
                XCTAssertEqual(AudioServiceTests.expectedValidateRequest, request)
                AudioServiceTests.expectRequest.fulfill()
            case .end:
                context.statusPromise.succeed(.ok)
            }
        }

        assertRequestMetadata(context: context, accessToken: AudioServiceTests.mockToken)
        _ = context.sendResponse(AudioServiceTests.expectedValidateResponse)
        return context.eventLoop.makeSucceededFuture(handle(_:))
    }

    func createEnrolledEvent(
        context: GRPC.StreamingResponseCallContext<SensoryCloud.Sensory_Api_V1_Audio_CreateEnrollmentResponse>) -> NIOCore.EventLoopFuture<(GRPC.StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_CreateEnrolledEventRequest>) -> Void>
    {
        func handle(_ event: StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_CreateEnrolledEventRequest>) {
            switch event {
            case .message(let request):
                XCTAssertEqual(AudioServiceTests.expectedEnrollEventRequest, request)
                AudioServiceTests.expectRequest.fulfill()
            case .end:
                context.statusPromise.succeed(.ok)
            }
        }

        assertRequestMetadata(context: context, accessToken: AudioServiceTests.mockToken)
        _ = context.sendResponse(AudioServiceTests.expectedEnrollEventResponse)
        return context.eventLoop.makeSucceededFuture(handle(_:))
    }

    func validateEnrolledEvent(
        context: GRPC.StreamingResponseCallContext<SensoryCloud.Sensory_Api_V1_Audio_ValidateEnrolledEventResponse>) -> NIOCore.EventLoopFuture<(GRPC.StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_ValidateEnrolledEventRequest>) -> Void>
    {
        func handle(_ event: StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_ValidateEnrolledEventRequest>) {
            switch event {
            case .message(let request):
                XCTAssertEqual(AudioServiceTests.expectedValidateEnrolledEventRequest, request)
                AudioServiceTests.expectRequest.fulfill()
            case .end:
                context.statusPromise.succeed(.ok)
            }
        }

        assertRequestMetadata(context: context, accessToken: AudioServiceTests.mockToken)
        _ = context.sendResponse(AudioServiceTests.expectedValidateEnrolledEventResponse)
        return context.eventLoop.makeSucceededFuture(handle(_:))
    }
}

final class AudioTranscriptionsProvider: Sensory_Api_V1_Audio_AudioTranscriptionsProvider {
    var interceptors: SensoryCloud.Sensory_Api_V1_Audio_AudioTranscriptionsServerInterceptorFactoryProtocol? = nil

    func transcribe(
        context: GRPC.StreamingResponseCallContext<SensoryCloud.Sensory_Api_V1_Audio_TranscribeResponse>) -> NIOCore.EventLoopFuture<(GRPC.StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_TranscribeRequest>) -> Void>
    {
        func handle(_ event: StreamEvent<SensoryCloud.Sensory_Api_V1_Audio_TranscribeRequest>) {
            switch event {
            case .message(let request):
                XCTAssertEqual(AudioServiceTests.expectedTranscribeRequest, request)
                AudioServiceTests.expectRequest.fulfill()
            case .end:
                context.statusPromise.succeed(.ok)
            }
        }

        assertRequestMetadata(context: context, accessToken: AudioServiceTests.mockToken)
        _ = context.sendResponse(AudioServiceTests.expectedTranscribeResponse)
        return context.eventLoop.makeSucceededFuture(handle(_:))    }
}

final class AudioSynthesisProvider: Sensory_Api_V1_Audio_AudioSynthesisProvider {
    var interceptors: SensoryCloud.Sensory_Api_V1_Audio_AudioSynthesisServerInterceptorFactoryProtocol? = nil

    func synthesizeSpeech(
        request: SensoryCloud.Sensory_Api_V1_Audio_SynthesizeSpeechRequest,
        context: GRPC.StreamingResponseCallContext<SensoryCloud.Sensory_Api_V1_Audio_SynthesizeSpeechResponse>) -> NIOCore.EventLoopFuture<GRPC.GRPCStatus>
    {
        assertRequestMetadata(context: context, accessToken: AudioServiceTests.mockToken)
        XCTAssertEqual(AudioServiceTests.expectedSynthesisRequest, request)
        AudioServiceTests.expectRequest.fulfill()
        _ = context.sendResponse(AudioServiceTests.expectedSynthesisResponse)
        return context.eventLoop.makeSucceededFuture(.ok)
    }
}
