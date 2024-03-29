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

/// Represents either an enrollment ID or an enrollment group ID to authenticate against
public enum EnrollmentIdentifier {
    /// Represents an enrollment ID
    case enrollmentID(String)
    /// Represents an enrollment group ID
    case enrollmentGroupID(String)
}

extension Sensory_Api_V1_Audio_AudioModelsNIOClient: GrpcClient {
    init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

extension Sensory_Api_V1_Audio_AudioBiometricsNIOClient: GrpcClient {
    init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

extension Sensory_Api_V1_Audio_AudioEventsNIOClient: GrpcClient {
    init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

extension Sensory_Api_V1_Audio_AudioTranscriptionsNIOClient: GrpcClient {
    init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

extension Sensory_Api_V1_Audio_AudioSynthesisNIOClient: GrpcClient {
    init(grpcChannel: GRPCChannel) {
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

    /// Fetches a list of the current audio models supported by the cloud host
    ///  - Returns: A future to be fulfilled with either a list of available models, or the network error that occurred
    public func getModels() -> EventLoopFuture<Sensory_Api_V1_Audio_GetModelsResponse> {
        do {
            let client: Sensory_Api_V1_Audio_AudioModelsNIOClient = try service.getClient()
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
    ///   - userID: Unique user identifier
    ///   - languageCode: Preferred language code for the user, pass in nil to use the value from config
    ///   - description: User supplied description of the enrollment
    ///   - isLivenessEnabled: Verifies liveness during the enrollment process
    ///   - numUtterances: Sets how many utterances should be required for text-dependent enrollments, defaults to 4 if not specified.
    ///         This parameter should be left `nil` for text-independent enrollments
    ///   - enrollmentDuration: Sets the duration in seconds for text-independent enrollments, defaults to 12.5 without liveness enabled and 8 with liveness enabled.
    ///         This parameter should be left `nil` for text-dependent enrollments
    ///   - disableServerEnrollmentStorage: If true this will prevent the server from storing enrollment tokens locally and always force it to
    ///         return a token upon successful enrollment regardless of server configuration
    ///   - onStreamReceive: Handler function to handle response sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Throws: `NetworkError.notInitialized` if `Config.deviceID` has not been set
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func createEnrollment(
        modelName: String,
        userID: String,
        languageCode: String? = nil,
        description: String = "",
        isLivenessEnabled: Bool,
        numUtterances: UInt32? = nil,
        enrollmentDuration: Float? = nil,
        disableServerEnrollmentStorage: Bool = false,
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_CreateEnrollmentResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Audio_CreateEnrollmentRequest,
        Sensory_Api_V1_Audio_CreateEnrollmentResponse
    > {
        guard let deviceID = Config.deviceID else {
            throw NetworkError.notInitialized
        }

        // Establish grpc streaming
        let client: Sensory_Api_V1_Audio_AudioBiometricsNIOClient = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.createEnrollment(callOptions: metadata, handler: onStreamReceive)

        // Send initial config message
        var audioConfig = Sensory_Api_V1_Audio_AudioConfig()
        audioConfig.encoding = .linear16
        audioConfig.sampleRateHertz = Int32(Config.audioSampleRate)
        audioConfig.audioChannelCount = 1
        audioConfig.languageCode = languageCode ?? Config.languageCode

        var config = Sensory_Api_V1_Audio_CreateEnrollmentConfig()
        config.audio = audioConfig
        config.modelName = modelName
        config.userID = userID
        config.deviceID = deviceID
        config.description_p = description
        config.isLivenessEnabled = isLivenessEnabled
        if let utterances = numUtterances {
            config.enrollmentNumUtterances = utterances
        } else if let duration = enrollmentDuration {
            config.enrollmentDuration = duration
        }
        config.disableServerEnrollmentTemplateStorage = disableServerEnrollmentStorage

        var request = Sensory_Api_V1_Audio_CreateEnrollmentRequest()
        request.config = config

        call.sendMessage(request, promise: nil)

        return call
    }

    /// Opens a bidirectional stream to the server for the purpose of authentication
    ///
    /// This call will automatically send the initial `AudioConfig` message to the server
    /// - Parameters:
    ///   - enrollment: enrollment or enrollment group to authenticate against
    ///   - languageCode: Preferred language code for the user, pass in nil to use the value from config
    ///   - isLivenessEnabled: Specifies if the authentication should include a liveness check
    ///   - enrollmentToken: Encrypted enrollment token that was provided on enrollment, pass nil if no token was provided
    ///   - onStreamReceive: Handler function to handle response sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func authenticate(
        enrollment: EnrollmentIdentifier,
        languageCode: String? = nil,
        isLivenessEnabled: Bool,
        enrollmentToken: Data? = nil,
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_AuthenticateResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Audio_AuthenticateRequest,
        Sensory_Api_V1_Audio_AuthenticateResponse
    > {
        // Establish grpc streaming
        let client: Sensory_Api_V1_Audio_AudioBiometricsNIOClient = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.authenticate(callOptions: metadata, handler: onStreamReceive)

        // Send initial config message
        var audioConfig = Sensory_Api_V1_Audio_AudioConfig()
        audioConfig.encoding = .linear16
        audioConfig.sampleRateHertz = Int32(Config.audioSampleRate)
        audioConfig.audioChannelCount = 1
        audioConfig.languageCode = languageCode ?? Config.languageCode

        var config = Sensory_Api_V1_Audio_AuthenticateConfig()
        config.audio = audioConfig
        switch enrollment {
        case .enrollmentID(let enrollmentID):
            config.enrollmentID = enrollmentID
        case .enrollmentGroupID(let groupID):
            config.enrollmentGroupID = groupID
        }
        config.isLivenessEnabled = isLivenessEnabled
        if let token = enrollmentToken {
            config.enrollmentToken = token
        }

        var request = Sensory_Api_V1_Audio_AuthenticateRequest()
        request.config = config

        call.sendMessage(request, promise: nil)

        return call
    }

    /// Opens a bidirectional stream to the server for the purpose of audio event validation
    ///
    /// This call will automatically send the initial `AudioConfig` message to the server
    /// - Parameters:
    ///   - modelName: Name of model to validate
    ///   - userID: Unique user identifier
    ///   - languageCode: Preferred language code for the user, pass in nil to use the value from config
    ///   - sensitivity: How sensitive the model should be to false accepts
    ///   - topN: When using the topN model, this determines how many results are returned
    ///   - onStreamReceive: Handler function to handle response sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func validateTrigger(
        modelName: String,
        userID: String,
        languageCode: String? = nil,
        sensitivity: Sensory_Api_V1_Audio_ThresholdSensitivity,
        topN: Int32 = 5,
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_ValidateEventResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Audio_ValidateEventRequest,
        Sensory_Api_V1_Audio_ValidateEventResponse
    > {
        // Establish grpc streaming
        let client: Sensory_Api_V1_Audio_AudioEventsNIOClient = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.validateEvent(callOptions: metadata, handler: onStreamReceive)

        // Send initial config message
        var audioConfig = Sensory_Api_V1_Audio_AudioConfig()
        audioConfig.encoding = .linear16
        audioConfig.sampleRateHertz = Int32(Config.audioSampleRate)
        audioConfig.audioChannelCount = 1
        audioConfig.languageCode = languageCode ?? Config.languageCode

        var config = Sensory_Api_V1_Audio_ValidateEventConfig()
        config.audio = audioConfig
        config.modelName = modelName
        config.userID = userID
        config.sensitivity = sensitivity
        config.topN = topN

        var request = Sensory_Api_V1_Audio_ValidateEventRequest()
        request.config = config

        call.sendMessage(request, promise: nil)

        return call
    }

    /// Opens a bidirectional stream for the purpose of creating an enrolled audio event
    ///
    /// This call will automatically send the initial `AudioConfig` message to the server
    /// - Parameters:
    ///   - modelName: Name of model to enroll against
    ///   - userID: Unique user identifier
    ///   - languageCode: Preferred language code for the user, pass in nil to use the value from config
    ///   - description: User supplied description of the enrollment
    ///   - onStreamReceive: Handler function to handle responses sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func streamCreateEnrolledEvent(
        modelName: String,
        userID: String,
        languageCode: String? = nil,
        description: String = "",
        disableServerEnrollmentStorage: Bool = false,
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_CreateEnrollmentResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Audio_CreateEnrolledEventRequest,
        Sensory_Api_V1_Audio_CreateEnrollmentResponse
    > {
        let client: Sensory_Api_V1_Audio_AudioEventsNIOClient = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.createEnrolledEvent(callOptions: metadata, handler: onStreamReceive)

        var audioConfig = Sensory_Api_V1_Audio_AudioConfig()
        audioConfig.encoding = .linear16
        audioConfig.sampleRateHertz = Int32(Config.audioSampleRate)
        audioConfig.audioChannelCount = 1
        audioConfig.languageCode = languageCode ?? Config.languageCode

        var config = Sensory_Api_V1_Audio_CreateEnrollmentEventConfig()
        config.audio = audioConfig
        config.modelName = modelName
        config.userID = userID
        config.description_p = description

        var request = Sensory_Api_V1_Audio_CreateEnrolledEventRequest()
        request.config = config

        call.sendMessage(request, promise: nil)

        return call
    }

    /// Opens a bidirectional stream for the purpose of validating against an enrolled audio event
    ///
    /// This call will automatically send the initial `AudioConfig` message to the server
    /// - Parameters:
    ///   - enrollment: enrollment or enrollment group to validate against
    ///   - languageCode: Preferred language code for the user, pass in nil to use the value from config
    ///   - sensitivity: How sensitive the model should be to false accepts
    ///   - enrollmentToken: Encrypted enrollment token that was provided on enrollment, pass nil if no token was provided
    ///   - onStreamReceive: Handler function to handle responses sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func streamValidateEnrolledEvent(
        enrollment: EnrollmentIdentifier,
        languageCode: String? = nil,
        sensitivity: Sensory_Api_V1_Audio_ThresholdSensitivity,
        enrollmentToken: Data? = nil,
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_ValidateEnrolledEventResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Audio_ValidateEnrolledEventRequest,
        Sensory_Api_V1_Audio_ValidateEnrolledEventResponse
    > {
        let client: Sensory_Api_V1_Audio_AudioEventsNIOClient = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.validateEnrolledEvent(callOptions: metadata, handler: onStreamReceive)

        var audioConfig = Sensory_Api_V1_Audio_AudioConfig()
        audioConfig.encoding = .linear16
        audioConfig.sampleRateHertz = Int32(Config.audioSampleRate)
        audioConfig.audioChannelCount = 1
        audioConfig.languageCode = languageCode ?? Config.languageCode

        var config = Sensory_Api_V1_Audio_ValidateEnrolledEventConfig()
        switch enrollment {
        case .enrollmentID(let enrollmentID):
            config.enrollmentID = enrollmentID
        case .enrollmentGroupID(let groupID):
            config.enrollmentGroupID = groupID
        }
        config.audio = audioConfig
        config.sensitivity = sensitivity
        if let token = enrollmentToken {
            config.enrollmentToken = token
        }

        var request = Sensory_Api_V1_Audio_ValidateEnrolledEventRequest()
        request.config = config
        call.sendMessage(request, promise: nil)

        return call
    }

    /// Opens a bidirectional stream to the server that provides a transcription of the provided audio data
    ///
    /// This call will automatically send the initial `AudioConfig` message to the server.
    /// - Note: The final message sent on the returned stream *must* include a post-processing action of FINAL
    /// - Parameters:
    ///   - modelName: Name of model to validate
    ///   - userID: Unique user identifier
    ///   - languageCode: Preferred language code for the user, pass in nil to use the value from config
    ///   - enablePunctuationCapitalization: If true, the resulting transcript will include punctuation and capitalization
    ///   - doSingleUtterance: If true, the server will automatically close the stream once the user stops talking
    ///   - vadSensitivity: The sensitivity of the voice activity detector. Defaults to `low`
    ///   - vadDuration: The duration of silence to detect before automatically closing the stream as a number of seconds. Defaults to 1
    ///   - doOfflineMode: Enables offline transcriptions. This mode is optimized for uploading audio files instead of streaming from a microphone.
    ///   - wakewordModel: Optional wakeword model to require recognition on before beginning a transcript, leave nil to disable
    ///   - wakewordSensitivity: The sensitivity to use for the wakeword model, ignored if wakeword model is nil
    ///   - onStreamReceive: Handler function to handle response sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func transcribeAudio(
        modelName: String,
        userID: String,
        languageCode: String? = nil,
        enablePunctuationCapitalization: Bool = false,
        doSingleUtterance: Bool = false,
        vadSensitivity: Sensory_Api_V1_Audio_ThresholdSensitivity = .low,
        vadDuration: Float = 1,
        doOfflineMode: Bool = false,
        wakewordModel: String? = nil,
        wakewordSensitivity: Sensory_Api_V1_Audio_ThresholdSensitivity = .low,
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_TranscribeResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Audio_TranscribeRequest,
        Sensory_Api_V1_Audio_TranscribeResponse
    > {
        // Establish grpc streaming
        let client: Sensory_Api_V1_Audio_AudioTranscriptionsNIOClient = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.transcribe(callOptions: metadata, handler: onStreamReceive)

        // Send initial config message
        var audioConfig = Sensory_Api_V1_Audio_AudioConfig()
        audioConfig.encoding = .linear16
        audioConfig.sampleRateHertz = Int32(Config.audioSampleRate)
        audioConfig.audioChannelCount = 1
        audioConfig.languageCode = languageCode ?? Config.languageCode

        var config = Sensory_Api_V1_Audio_TranscribeConfig()
        config.audio = audioConfig
        config.modelName = modelName
        config.userID = userID
        config.enablePunctuationCapitalization = enablePunctuationCapitalization
        config.doSingleUtterance = doSingleUtterance
        config.vadSensitivity = vadSensitivity
        config.vadDuration = vadDuration
        config.doOfflineMode = doOfflineMode

        if let wakewordModel = wakewordModel {
            var wakewordConfig = Sensory_Api_V1_Audio_TranscribeEventConfig()
            wakewordConfig.modelName = wakewordModel
            wakewordConfig.sensitivity = wakewordSensitivity
            config.wakeWordConfig = wakewordConfig
        }

        var request = Sensory_Api_V1_Audio_TranscribeRequest()
        request.config = config

        call.sendMessage(request, promise: nil)

        return call
    }

    /// Sends a request to Sensory Cloud to synthesize speech
    ///
    /// Concatenating all of the `audioContent` of the responses passed to the `onStreamReceive` handler will result in a complete WAV file of the resultant audio
    /// - Parameters:
    ///   - phrase: The text phrase to synthesize a voice saying
    ///   - modelName: The name of the model to use for speech synthesis
    ///   - sampleRateHertz The desired sample rate of the synthesized audio, 16000Hz should be used in most cases
    ///   - onStreamReceive: Handler function to handle responses sent from the server
    /// - Returns: ServerStreamingCall object, can be used to prematurely close the grpc stream.
    public func synthesizeSpeech(
        phrase: String,
        modelName: String,
        sampleRateHertz: Int32,
        onStreamReceive: @escaping ((Sensory_Api_V1_Audio_SynthesizeSpeechResponse) -> Void)
    ) throws -> ServerStreamingCall<
        Sensory_Api_V1_Audio_SynthesizeSpeechRequest,
        Sensory_Api_V1_Audio_SynthesizeSpeechResponse
    > {
        // Build request message
        var voiceConfig = Sensory_Api_V1_Audio_VoiceSynthesisConfig()
        voiceConfig.modelName = modelName
        voiceConfig.sampleRateHertz = sampleRateHertz

        var request = Sensory_Api_V1_Audio_SynthesizeSpeechRequest()
        request.phrase = phrase
        request.config = voiceConfig

        // Open grpc stream
        let client: Sensory_Api_V1_Audio_AudioSynthesisNIOClient = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.synthesizeSpeech(request, callOptions: metadata, handler: onStreamReceive)

        return call
    }
}
