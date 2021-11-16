//
//  AudioService.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation
import GRPC
import NIO
import NIOHPACK

extension Sensory_Api_V1_Audio_AudioModelsClient: GrpcClient {
    convenience init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

extension Sensory_Api_V1_Audio_AudioBiometricsClient: GrpcClient {
    convenience init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

extension Sensory_Api_V1_Audio_AudioEventsClient: GrpcClient {
    convenience init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

/// A collection of grpc service calls for using audio models through Sensory Cloud
public class AudioService {

    var service: Service

    /// Initializes a new instance of `AudioService`
    public init() {
        self.service = Service.shared
    }

    /// Internal initializer, used for unit testing
    init(service: Service) {
        self.service = service
    }

    /// Fetches a list of the current audio models supported by the cloud host
    ///  - Returns: A future to be fulfilled with either a list of available models, or the network error that occurred
    public func getModels() -> EventLoopFuture<Sensory_Api_V1_Audio_GetModelsResponse> {
        NSLog("Requesting voice biometric models from server")

        do {
            let client: Sensory_Api_V1_Audio_AudioModelsClientProtocol = try service.getClient()
            let metadata = try service.getDefaultMetadata(isUnary: true)

            let request = Sensory_Api_V1_Audio_GetModelsRequest()
            return client.getModels(request, callOptions: metadata).response
        } catch {
            return service.group.next().makeFailedFuture(error)
        }
    }

    /// Opens a bidirectional stream to the server for the purpose of creating an audio enrollment
    ///
    /// This call will automatically send the initial `AudioConfig` message to the server
    /// - Parameters:
    ///   - modelName: Name of model to validate
    ///   - sampleRate: Sample rate of model to validate
    ///   - userID: Unique user identifier
    ///   - description: User supplied description of the enrollment
    ///   - onStreamReceive: Handler function to handle response sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Throws: `NetworkError.notInitialized` if `Config.deviceID` has not been set
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func createEnrollment(
        modelName: String,
        sampleRate: Int32,
        userID: String,
        description: String = "",
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_CreateEnrollmentResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Audio_CreateEnrollmentRequest,
        Sensory_Api_V1_Audio_CreateEnrollmentResponse
    > {
        NSLog("Starting audio enrollment stream")
        guard let deviceID = Config.deviceID else {
            throw NetworkError.notInitialized
        }

        // Establish grpc streaming
        let client: Sensory_Api_V1_Audio_AudioBiometricsClientProtocol = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.createEnrollment(callOptions: metadata, handler: onStreamReceive)

        // Send initial config message
        var audioConfig = Sensory_Api_V1_Audio_AudioConfig()
        audioConfig.encoding = .linear16
        audioConfig.sampleRateHertz = sampleRate
        audioConfig.audioChannelCount = 1
        audioConfig.languageCode = Config.languageCode

        var config = Sensory_Api_V1_Audio_CreateEnrollmentConfig()
        config.audio = audioConfig
        config.modelName = modelName
        config.userID = userID
        config.deviceID = deviceID
        config.description_p = description

        var request = Sensory_Api_V1_Audio_CreateEnrollmentRequest()
        request.config = config

        call.sendMessage(request, promise: nil)

        return call
    }

    /// Opens a bidirectional stream to the server for the purpose of authentication against an audio enrollment
    ///
    /// This call will automatically send the initial `AudioConfig` message to the server
    /// - Parameters:
    ///   - enrollmentID: Enrollment to authenticate against
    ///   - sampleRate: Sample rate of model to validate
    ///   - onStreamReceive: Handler function to handle response sent form the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func authenticate(
        enrollmentID: String,
        sampleRate: Int32,
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_AuthenticateResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Audio_AuthenticateRequest,
        Sensory_Api_V1_Audio_AuthenticateResponse
    > {
        return try streamAuthenticate(
            enrollmentID: enrollmentID,
            groupID: "",
            sampleRate: sampleRate,
            onStreamReceive: onStreamReceive
        )
    }

    /// Opens a bidirectional stream to the server for the purpose of authentication against an audio enrollment group
    ///
    /// This call will automatically send the initial `AudioConfig` message to the server
    /// - Parameters:
    ///   - groupID: Enrollment group to authenticate against
    ///   - sampleRate: Sample rate of model to validate
    ///   - onStreamReceive: Handler function to handle response sent form the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func authenticate(
        groupID: String,
        sampleRate: Int32,
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_AuthenticateResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Audio_AuthenticateRequest,
        Sensory_Api_V1_Audio_AuthenticateResponse
    > {
        return try streamAuthenticate(
            enrollmentID: "",
            groupID: groupID,
            sampleRate: sampleRate,
            onStreamReceive: onStreamReceive
        )
    }

    /// Opens a bidirectional stream to the server for the purpose of audio event validation
    ///
    /// This call will automatically send the initial `AudioConfig` message to the server
    /// - Parameters:
    ///   - modelName: Name of model to validate
    ///   - sampleRate: Sample rate of model to validate
    ///   - userID: Unique user identifier
    ///   - sensitivity: How sensitive the model should be to false accepts
    ///   - onStreamReceive: Handler function to handle response sent form the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func validateTrigger(
        modelName: String,
        sampleRate: Int32,
        userID: String,
        sensitivity: Sensory_Api_V1_Audio_ThresholdSensitivity,
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_ValidateEventResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Audio_ValidateEventRequest,
        Sensory_Api_V1_Audio_ValidateEventResponse
    > {
        NSLog("Requesting validate trigger stream from server")

        // Establish grpc streaming
        let client: Sensory_Api_V1_Audio_AudioEventsClientProtocol = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.validateEvent(callOptions: metadata, handler: onStreamReceive)

        // Send initial config message
        var audioConfig = Sensory_Api_V1_Audio_AudioConfig()
        audioConfig.encoding = .linear16
        audioConfig.sampleRateHertz = sampleRate
        audioConfig.audioChannelCount = 1
        audioConfig.languageCode = Config.languageCode

        var config = Sensory_Api_V1_Audio_ValidateEventConfig()
        config.audio = audioConfig
        config.modelName = modelName
        config.userID = userID
        config.sensitivity = sensitivity

        var request = Sensory_Api_V1_Audio_ValidateEventRequest()
        request.config = config

        call.sendMessage(request, promise: nil)

        return call
    }

    /// Opens a bidirectional stream to the server for the purpose of authentication
    ///
    /// This call will automatically send the initial `AudioConfig` message to the server
    /// - Parameters:
    ///   - enrollmentID: Enrollment to authenticate against
    ///   - groupID: enrollment group ID to authenticate against, enrollmentID will overwrite groupID if both are passed in
    ///   - sampleRate: Sample rate of model to validate
    ///   - onStreamReceive: Handler function to handle response sent form the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    func streamAuthenticate(
        enrollmentID: String,
        groupID: String,
        sampleRate: Int32,
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_AuthenticateResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Audio_AuthenticateRequest,
        Sensory_Api_V1_Audio_AuthenticateResponse
    > {
        NSLog("Starting audio authentication stream")

        // Establish grpc streaming
        let client: Sensory_Api_V1_Audio_AudioBiometricsClientProtocol = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.authenticate(callOptions: metadata, handler: onStreamReceive)

        // Send initial config message
        var audioConfig = Sensory_Api_V1_Audio_AudioConfig()
        audioConfig.encoding = .linear16
        audioConfig.sampleRateHertz = sampleRate
        audioConfig.audioChannelCount = 1
        audioConfig.languageCode = Config.languageCode

        var config = Sensory_Api_V1_Audio_AuthenticateConfig()
        config.audio = audioConfig
        if enrollmentID != "" {
            config.enrollmentID = enrollmentID
        } else {
            config.enrollmentGroupID = groupID
        }

        var request = Sensory_Api_V1_Audio_AuthenticateRequest()
        request.config = config

        call.sendMessage(request, promise: nil)

        return call
    }
}
