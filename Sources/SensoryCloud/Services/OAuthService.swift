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

            let client = try getClient(host: host)
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
    func getClient(host: CloudHost) throws -> Sensory_Api_Oauth_OauthServiceClientProtocol {
        let channel = try GRPCChannelPool.with(
            target: .host(host.host, port: host.port),
            transportSecurity: host.isSecure ? .tls(GRPCTLSConfiguration.makeClientConfigurationBackedByNIOSSL()) : .plaintext,
            eventLoopGroup: group
        )

        return Sensory_Api_Oauth_OauthServiceClient(channel: channel)
    }
}
