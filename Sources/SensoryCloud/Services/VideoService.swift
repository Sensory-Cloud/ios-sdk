//
//  VideoService.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation
import GRPC
import NIO
import NIOHPACK

extension Sensory_Api_V1_Video_VideoModelsClient: GrpcClient {
    convenience init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

extension Sensory_Api_V1_Video_VideoBiometricsClient: GrpcClient {
    convenience init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

extension Sensory_Api_V1_Video_VideoRecognitionClient: GrpcClient {
    convenience init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

/// A collection of grpc service calls for using vision models through Sensory Cloud
public class VideoService {

    var service: Service

    /// Initializes a new instance of `VideoService`
    public init() {
        self.service = Service.shared
    }

    /// Internal initializer, used for unit testing
    init(service: Service) {
        self.service = service
    }

    /// Fetches a list of the current vision models supported by the cloud host
    ///  - Returns: A future to be fulfilled with either a list of available models, or the network error that occurred
    public func getModels() -> EventLoopFuture<Sensory_Api_V1_Video_GetModelsResponse> {
        NSLog("Requesting video models from server")

        do {
            let client: Sensory_Api_V1_Video_VideoModelsClientProtocol = try service.getClient()
            let metadata = try service.getDefaultMetadata(isUnary: true)

            let request = Sensory_Api_V1_Video_GetModelsRequest()
            return client.getModels(request, callOptions: metadata).response
        } catch {
            return service.group.next().makeFailedFuture(error)
        }
    }

    /// Opens a bidirectional stream to the server for the purpose of creating a video enrollment
    ///
    /// This call will automatically send the initial `videoConfig` message to the server
    /// - Parameters:
    ///   - modelName: Name of model to create enrollment for
    ///   - userID: Unique user identifier
    ///   - description: User supplied description of the enrollment
    ///   - isLivenessEnabled: Determines if a liveness check should be conducted as well as an enrollment
    ///   - livenessThreshold: Liveness threshold for the potential liveness check
    ///   - numLiveFramesRequired: The number of frames that need to pass the liveness check for a successful enrollment (if liveness is enabled).
    ///         A value of 0 means that *all * frames need to pass the liveness check
    ///   - onStreamReceive: Handler function to handle responses sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Throws: `NetworkError.notInitialized` if `Config.deviceID` has not been set
    /// - Returns: Bidirectional stream that can be used to send video data to the server
    public func createEnrollment(
        modelName: String,
        userID: String,
        description: String = "",
        isLivenessEnabled: Bool = false,
        livenessThreshold: Sensory_Api_V1_Video_RecognitionThreshold = .low,
        numLiveFramesRequired: Int32 = 0,
        onStreamReceive: @escaping ((Sensory_Api_V1_Video_CreateEnrollmentResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Video_CreateEnrollmentRequest,
        Sensory_Api_V1_Video_CreateEnrollmentResponse
    > {
        NSLog("Starting video enrollment stream")
        guard let deviceID = Config.deviceID else {
            throw NetworkError.notInitialized
        }

        // Establish grpc streaming
        let client: Sensory_Api_V1_Video_VideoBiometricsClientProtocol = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.createEnrollment(callOptions: metadata, handler: onStreamReceive)

        // Send initial config message
        var config = Sensory_Api_V1_Video_CreateEnrollmentConfig()
        config.modelName = modelName
        config.userID = userID
        config.deviceID = deviceID
        config.description_p = description
        config.isLivenessEnabled = isLivenessEnabled
        config.livenessThreshold = livenessThreshold
        config.numLivenessFramesRequired = numLiveFramesRequired

        var request = Sensory_Api_V1_Video_CreateEnrollmentRequest()
        request.config = config

        call.sendMessage(request, promise: nil)

        return call
    }

    /// Opens a bidirectional stream to the server for the purpose of video authentication
    ///
    /// This call will automatically send the initial `VideoConfig` message to the server
    /// - Parameters:
    ///   - enrollment: enrollment or enrollment group to authenticate against
    ///   - isLivenessEnabled: Determines if a liveness check should be conducted as well as an enrollment
    ///   - livenessThreshold: Liveness threshold for the potential liveness check
    ///   - enrollmentToken: Encrypted enrollment token that was provided on enrollment, pass nil if no token was provided
    ///   - onStreamReceive: Handler function to handle responses sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func authenticate(
        enrollment: EnrollmentIdentifier,
        isLivenessEnabled: Bool = false,
        livenessThreshold: Sensory_Api_V1_Video_RecognitionThreshold = .low,
        enrollmentToken: Data? = nil,
        onStreamReceive: @escaping ((Sensory_Api_V1_Video_AuthenticateResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Video_AuthenticateRequest,
        Sensory_Api_V1_Video_AuthenticateResponse
    > {
        NSLog("Starting video authentication stream")

        // Establish grpc streaming
        let client: Sensory_Api_V1_Video_VideoBiometricsClientProtocol = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.authenticate(callOptions: metadata, handler: onStreamReceive)

        // Send initial config message
        var config = Sensory_Api_V1_Video_AuthenticateConfig()
        switch enrollment {
        case .enrollmentID(let enrollmentID):
            config.enrollmentID = enrollmentID
        case .enrollmentGroupID(let groupID):
            config.enrollmentGroupID = groupID
        }
        config.isLivenessEnabled = isLivenessEnabled
        config.livenessThreshold = livenessThreshold
        if let token = enrollmentToken {
            config.enrollmentToken = token
        }

        var request = Sensory_Api_V1_Video_AuthenticateRequest()
        request.config = config

        call.sendMessage(request, promise: nil)

        return call
    }

    /// Opens a bidirectional stream to the server for the purpose of validating the liveness of an image stream
    ///
    /// This call will automatically send the initial `VideoConfig` message to the server
    /// - Parameters:
    ///   - modelName: Name of the model to use
    ///   - userID: Unique user identifier
    ///   - threshold: Threshold of how confident the model has to be to give a positive liveness result
    ///   - onStreamReceive: Handler function to handle responses sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to push image data to the server
    public func validateLiveness(
        modelName: String,
        userID: String,
        threshold: Sensory_Api_V1_Video_RecognitionThreshold,
        onStreamReceive: @escaping ((Sensory_Api_V1_Video_LivenessRecognitionResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Video_ValidateRecognitionRequest,
        Sensory_Api_V1_Video_LivenessRecognitionResponse
    > {
        NSLog("Requesting Liveness stream from server")

        // Establish grpc streaming
        let client: Sensory_Api_V1_Video_VideoRecognitionClientProtocol = try service.getClient()
        let metadata = try service.getDefaultMetadata()
        let call = client.validateLiveness(callOptions: metadata, handler: onStreamReceive)

        // Send initial config message
        var videoConfig = Sensory_Api_V1_Video_ValidateRecognitionConfig()
        videoConfig.modelName = modelName
        videoConfig.userID = userID
        videoConfig.threshold = threshold

        var request = Sensory_Api_V1_Video_ValidateRecognitionRequest()
        request.config = videoConfig

        call.sendMessage(request, promise: nil)

        return call
    }
}
