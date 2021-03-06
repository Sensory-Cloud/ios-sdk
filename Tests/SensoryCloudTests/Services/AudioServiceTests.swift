//
//  AudioServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/10/21.
//

import XCTest
@testable import SensoryCloud
import CoreMedia

final class AudioServiceTests: XCTestCase {

    var mockService = MockService()
    var expectResponse = XCTestExpectation(description: "grpc response should be received")
    var expectRequestMetadata = XCTestExpectation(description: "request metadata should be sent")
    var expectRequest = XCTestExpectation(description: "grpc request should be sent")

    var mockAudioConfig: Sensory_Api_V1_Audio_AudioConfig {
        var config = Sensory_Api_V1_Audio_AudioConfig()
        config.encoding = .linear16
        config.sampleRateHertz = 16000
        config.audioChannelCount = 1
        config.languageCode = Config.languageCode
        return config
    }

    override func setUp() {
        resetExpectation()
        mockService.reset()
        Config.deviceID = nil
    }

    func resetExpectation() {
        expectResponse = XCTestExpectation(description: "grpc response should be received")
        expectRequestMetadata = XCTestExpectation(description: "request metadata should be sent")
        expectRequest = XCTestExpectation(description: "grpc request should be sent")
    }

    func testGetAudioModels() throws {
        let mockClient = Sensory_Api_V1_Audio_AudioModelsTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Audio_AudioModelsClientProtocol.self, client: mockClient)
        let audioService = AudioService(service: mockService)

        var audioModel = Sensory_Api_V1_Audio_AudioModel()
        audioModel.fixedPhrase = "phrase"
        audioModel.modelType = .soundEventEnrollable
        audioModel.name = "mock model"
        var expectedResponse = Sensory_Api_V1_Audio_GetModelsResponse()
        expectedResponse.models = [audioModel]

        let mockStream = mockClient.makeGetModelsResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultUnaryHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(Sensory_Api_V1_Audio_GetModelsRequest(), message)
                self?.expectRequest.fulfill()
            case .end:
                break
            }
        }

        let rsp = audioService.getModels()
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
        let mockClient = Sensory_Api_V1_Audio_AudioBiometricsTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Audio_AudioBiometricsClientProtocol.self, client: mockClient)
        let audioService = AudioService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Audio_CreateEnrollmentResponse()
        expectedResponse.audioEnergy = 0.5
        expectedResponse.percentComplete = 25

        Config.deviceID = "Mock Device ID"
        var enrollmentConfig = Sensory_Api_V1_Audio_CreateEnrollmentConfig()
        enrollmentConfig.audio = mockAudioConfig
        enrollmentConfig.modelName = "Mock Model Name"
        enrollmentConfig.userID = "Mock User ID"
        enrollmentConfig.deviceID = "Mock Device ID"
        enrollmentConfig.description_p = "Mock Description"
        enrollmentConfig.isLivenessEnabled = true
        enrollmentConfig.enrollmentNumUtterances = 5
        var expectedRequest = Sensory_Api_V1_Audio_CreateEnrollmentRequest()
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
                XCTFail("AudioService should not directly end the stream")
            }
        }

        _ = try audioService.createEnrollment(
            modelName: "Mock Model Name",
            userID: "Mock User ID",
            description: "Mock Description",
            isLivenessEnabled: true,
            numUtterances: 5,
            enrollmentDuration: 10 // Should be ignored since numUtterances is also specified
        ) { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        try mockStream.sendMessage(expectedResponse)

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testAuthenticateEnrollment() throws {
        let mockClient = Sensory_Api_V1_Audio_AudioBiometricsTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Audio_AudioBiometricsClientProtocol.self, client: mockClient)
        let audioService = AudioService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Audio_AuthenticateResponse()
        expectedResponse.audioEnergy = 0.5

        var authConfig = Sensory_Api_V1_Audio_AuthenticateConfig()
        authConfig.audio = mockAudioConfig
        authConfig.enrollmentID = "Mock Enrollment"
        authConfig.isLivenessEnabled = false
        var expectedRequest = Sensory_Api_V1_Audio_AuthenticateRequest()
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

        _ = try audioService.authenticate(
            enrollment: .enrollmentID("Mock Enrollment"),
            isLivenessEnabled: false
        ) { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        try mockStream.sendMessage(expectedResponse)

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testAuthenticateEnrollmentGroup() throws {
        let mockClient = Sensory_Api_V1_Audio_AudioBiometricsTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Audio_AudioBiometricsClientProtocol.self, client: mockClient)
        let audioService = AudioService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Audio_AuthenticateResponse()
        expectedResponse.audioEnergy = 0.5

        var authConfig = Sensory_Api_V1_Audio_AuthenticateConfig()
        authConfig.audio = mockAudioConfig
        authConfig.enrollmentGroupID = "Mock Enrollment Group"
        authConfig.isLivenessEnabled = true
        var expectedRequest = Sensory_Api_V1_Audio_AuthenticateRequest()
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

        _ = try audioService.authenticate(
            enrollment: .enrollmentGroupID("Mock Enrollment Group"),
            isLivenessEnabled: true
        ) { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        try mockStream.sendMessage(expectedResponse)

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testValidateTrigger() throws {
        let mockClient = Sensory_Api_V1_Audio_AudioEventsTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Audio_AudioEventsClientProtocol.self, client: mockClient)
        let audioService = AudioService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Audio_ValidateEventResponse()
        expectedResponse.audioEnergy = 0.25
        expectedResponse.success = true
        expectedResponse.resultID = "result"
        expectedResponse.score = 99

        var triggerConfig = Sensory_Api_V1_Audio_ValidateEventConfig()
        triggerConfig.audio = mockAudioConfig
        triggerConfig.modelName = "Trigger Model"
        triggerConfig.userID = "Some User"
        triggerConfig.sensitivity = .medium
        var expectedRequest = Sensory_Api_V1_Audio_ValidateEventRequest()
        expectedRequest.config = triggerConfig

        let mockStream = mockClient.makeValidateEventResponseStream { [weak self] part in
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

        _ = try audioService.validateTrigger(
            modelName: "Trigger Model",
            userID: "Some User",
            sensitivity: .medium
        ) { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        try mockStream.sendMessage(expectedResponse)

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testCreateEnrolledEvent() throws {
        let mockClient = Sensory_Api_V1_Audio_AudioEventsTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Audio_AudioEventsClientProtocol.self, client: mockClient)
        let audioService = AudioService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Audio_CreateEnrollmentResponse()
        expectedResponse.audioEnergy = 0.5
        expectedResponse.percentComplete = 25

        Config.deviceID = "Mock Device ID"
        var enrollmentConfig = Sensory_Api_V1_Audio_CreateEnrollmentEventConfig()
        enrollmentConfig.audio = mockAudioConfig
        enrollmentConfig.modelName = "Mock Model Name"
        enrollmentConfig.userID = "Mock User ID"
        enrollmentConfig.description_p = "Mock Description"
        var expectedRequest = Sensory_Api_V1_Audio_CreateEnrolledEventRequest()
        expectedRequest.config = enrollmentConfig

        let mockStream = mockClient.makeCreateEnrolledEventResponseStream() { [weak self] part in
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

        _ = try audioService.streamCreateEnrolledEvent(
            modelName: "Mock Model Name",
            userID: "Mock User ID",
            description: "Mock Description"
        ) { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        try mockStream.sendMessage(expectedResponse)

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testValidateEnrolledEvent() throws {
        let mockClient = Sensory_Api_V1_Audio_AudioEventsTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Audio_AudioEventsClientProtocol.self, client: mockClient)
        let audioService = AudioService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Audio_ValidateEnrolledEventResponse()
        expectedResponse.audioEnergy = 0.5

        var authConfig = Sensory_Api_V1_Audio_ValidateEnrolledEventConfig()
        authConfig.audio = mockAudioConfig
        authConfig.enrollmentID = "Mock Enrollment"
        authConfig.sensitivity = .highest
        var expectedRequest = Sensory_Api_V1_Audio_ValidateEnrolledEventRequest()
        expectedRequest.config = authConfig

        let mockStream = mockClient.makeValidateEnrolledEventResponseStream() { [weak self] part in
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

        _ = try audioService.streamValidateEnrolledEvent(
            enrollment: .enrollmentID("Mock Enrollment"),
            sensitivity: .highest
        ) { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        try mockStream.sendMessage(expectedResponse)

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testTranscribeAudio() throws {
        let mockClient = Sensory_Api_V1_Audio_AudioTranscriptionsTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Audio_AudioTranscriptionsClientProtocol.self, client: mockClient)
        let audioService = AudioService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Audio_TranscribeResponse()
        expectedResponse.audioEnergy = 0.25
        expectedResponse.transcript = "Some Transcription"

        var transcriptConfig = Sensory_Api_V1_Audio_TranscribeConfig()
        transcriptConfig.audio = mockAudioConfig
        transcriptConfig.modelName = "Transcript Model"
        transcriptConfig.userID = "Some User"
        var expectedRequest = Sensory_Api_V1_Audio_TranscribeRequest()
        expectedRequest.config = transcriptConfig

        let mockStream = mockClient.makeTranscribeResponseStream { [weak self] part in
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

        _ = try audioService.transcribeAudio(
            modelName: "Transcript Model",
            userID: "Some User"
        ) { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        try mockStream.sendMessage(expectedResponse)

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testSynthesizeSpeech() throws {
        let voiceName = "Some voice name"
        let phrase = "Some phrase to synthesize"

        let mockClient = Sensory_Api_V1_Audio_AudioSynthesisTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Audio_AudioSynthesisClientProtocol.self, client: mockClient)
        let audioService = AudioService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Audio_SynthesizeSpeechResponse()
        expectedResponse.config = mockAudioConfig
        expectedResponse.audioContent = Data(repeating: 10, count: 20)

        var voiceConfig = Sensory_Api_V1_Audio_VoiceSynthesisConfig()
        voiceConfig.voice = voiceName
        voiceConfig.audio = mockAudioConfig
        var expectedRequest = Sensory_Api_V1_Audio_SynthesizeSpeechRequest()
        expectedRequest.config = voiceConfig
        expectedRequest.phrase = phrase

        let mockStream = mockClient.makeSynthesizeSpeechResponseStream{ [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultStreamHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                // request stream will be automatically closed since this is a server streaming call
                break
            }
        }

        _ = try audioService.synthesizeSpeech(phrase: phrase, voiceName: voiceName) { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        try mockStream.sendMessage(expectedResponse)

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }
}
