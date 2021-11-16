//
//  OAuthService.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/3/21.
//

import Foundation
import GRPC
import NIO

/// A collection of grpc calls for enrolling and requesting OAuth tokens
public class OAuthService {

    let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

    /// Initializes a new instance of `OAuthService`
    public init() {}

    deinit {
        do {
            try group.syncShutdownGracefully()
        } catch {
            NSLog("Could not shutdown OAuth group gracefully: \(error.localizedDescription)")
        }
    }

    /// Creates a new device enrollment
    ///
    /// The credential string authenticates that this device is allowed to enroll. Depending on the server configuration
    /// the credential string may be one of multiple values:
    ///  - An empty string if no authentication is configured on the server
    ///  - A shared secret (password)
    ///  - A signed JWT
    ///
    /// `TokenManager` may be used for securely generating a clientID and clientSecret for this call
    ///
    /// This call will fail with `NetworkError.notInitialized` if `Config.deviceID` or `Config.tenantID` has not been set
    ///
    /// - Parameters:
    ///   - name: Name of the enrolling device
    ///   - credential: Credential string to authenticate that this device is allowed to enroll
    ///   - clientID: ClientID to use for OAuth token generation
    ///   - clientSecret: Client Secret to use for OAuth token generation
    /// - Returns: A future to be fulfilled with either the enrolled device, or the network error that occurred
    public func enrollDevice(
        name: String,
        credential: String,
        clientID: String,
        clientSecret: String
    ) -> EventLoopFuture<Sensory_Api_V1_Management_DeviceResponse> {
        NSLog("Enrolling device: %@", name)

        do {
            guard let deviceID = Config.deviceID, let tenantID = Config.tenantID, let host = Config.getCloudHost() else {
                throw NetworkError.notInitialized
            }

            let client = try getEnrollmentClient(host: host)
            let defaultTimeout = CallOptions(timeLimit: .timeout(.seconds(Config.grpcTimeout)))

            var request = Sensory_Api_V1_Management_EnrollDeviceRequest()
            var clientRequest = Sensory_Api_V1_Management_CreateGenericClientRequest()
            clientRequest.clientID = clientID
            clientRequest.secret = clientSecret
            request.name = name
            request.deviceID = deviceID
            request.tenantID = tenantID
            request.client = clientRequest
            request.credential = credential
            return client.enrollDevice(request, callOptions: defaultTimeout).response
        } catch {
            return group.next().makeFailedFuture(error)
        }
    }

    /// Requests a new OAuth token from the server
    ///
    /// - Parameters:
    ///   - clientID: Client id to use in token request
    ///   - secret: Client secret to use in token request
    /// - Returns: Future to be fulfilled with the new access token, or the network error that occurred
    public func getToken(clientID: String, secret: String) -> EventLoopFuture<Sensory_Api_Common_TokenResponse> {
        NSLog("Requesting OAuth Token with clientID %@", clientID)
        do {
            guard let host = Config.getCloudHost() else {
                throw NetworkError.notInitialized
            }

            let client = try getOAuthClient(host: host)
            let defaultTimeout = CallOptions(timeLimit: .timeout(.seconds(Config.grpcTimeout)))

            var request = Sensory_Api_Oauth_TokenRequest()
            request.clientID = clientID
            request.secret = secret
            return client.getToken(request, callOptions: defaultTimeout).response
        } catch {
            return group.next().makeFailedFuture(error)
        }
    }

    /// Fetches the grpc client class, `Service.getClient()` is not used to prevent a circular dependency between `Service` and `TokenManager`
    func getOAuthClient(host: CloudHost) throws -> Sensory_Api_Oauth_OauthServiceClientProtocol {
        let channel = try GRPCChannelPool.with(
            target: .host(host.host, port: host.port),
            transportSecurity: host.isSecure ? .tls(GRPCTLSConfiguration.makeClientConfigurationBackedByNIOSSL()) : .plaintext,
            eventLoopGroup: group
        )

        return Sensory_Api_Oauth_OauthServiceClient(channel: channel)
    }

    /// Fetches the grpc client class, `Service.getClient()` is not used to prevent a circular dependency between `Service` and `TokenManager`
    func getEnrollmentClient(host: CloudHost) throws -> Sensory_Api_V1_Management_DeviceServiceClientProtocol {
        let channel = try GRPCChannelPool.with(
            target: .host(host.host, port: host.port),
            transportSecurity: host.isSecure ? .tls(GRPCTLSConfiguration.makeClientConfigurationBackedByNIOSSL()) : .plaintext,
            eventLoopGroup: group
        )

        return Sensory_Api_V1_Management_DeviceServiceClient(channel: channel)
    }
}
