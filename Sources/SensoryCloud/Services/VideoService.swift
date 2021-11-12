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

public class VideoService {

    var service: Service

    public init() {
        self.service = Service.shared
    }

    init(service: Service) {
        self.service = service
    }

    /// Fetches a list of the current video models supported by the server
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
    ///   - deviceID: Unique device identifier
    ///   - description: User supplied description of the enrollment
    ///   - isLivenessEnabled: Determines if a liveness check should be conducted as well as an enrollment
    ///   - livenessThreshold: Liveness threshold for the potential liveness check
    ///   - onStreamReceive: Handler function to handle responses sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send video data to the server
    public func createEnrollment(
        modelName: String,
        userID: String,
        deviceID: String,
        description: String = "",
        isLivenessEnabled: Bool = false,
        livenessThreshold: Sensory_Api_V1_Video_RecognitionThreshold = .low,
        onStreamReceive: @escaping ((Sensory_Api_V1_Video_CreateEnrollmentResponse) -> Void)
    ) throws -> BidirectionalStreamingCall<
        Sensory_Api_V1_Video_CreateEnrollmentRequest,
        Sensory_Api_V1_Video_CreateEnrollmentResponse
    > {
        NSLog("Starting video enrollment stream")

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

        var request = Sensory_Api_V1_Video_CreateEnrollmentRequest()
        request.config = config

        call.sendMessage(request, promise: nil)

        return call
    }

    /// Opens a bidirectional stream to the server for the purpose of authentication
    ///
    /// This call will automatically send the initial `VideoConfig` message to the server
    /// - Parameters:
    ///   - enrollmentID: Enrollment to authenticate against
    ///   - isLivenessEnabled: Determines if a liveness check should be conducted as well as an enrollment
    ///   - livenessThreshold: Liveness threshold for the potential liveness check
    ///   - onStreamReceive: Handler function to handle responses sent from the server
    /// - Throws: `NetworkError` if an error occurs while processing the cached server url
    /// - Returns: Bidirectional stream that can be used to send audio data to the server
    public func authenticate(
        enrollmentID: String,
        isLivenessEnabled: Bool = false,
        livenessThreshold: Sensory_Api_V1_Video_RecognitionThreshold = .low,
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
        config.enrollmentID = enrollmentID
        config.isLivenessEnabled = isLivenessEnabled
        config.livenessThreshold = livenessThreshold

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
