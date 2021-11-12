//
//  OAuthService.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/3/21.
//

import Foundation
import GRPC
import NIO

/// Service responsible for requesting new OAuth tokens
///
/// - NOTE: This class does not depend on `Service` to avoid a circular dependency with `Service` and `TokenManager`
public class OAuthService {

    let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

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
    /// - Returns: Future to be fulfilled with the new access token
    public func getToken(clientID: String, secret: String) -> EventLoopFuture<Sensory_Api_Common_TokenResponse> {
        NSLog("Requesting OAuth Token with clientID %@", clientID)
        do {
            guard let host = Config.getCloudHost() else {
                throw NetworkError.notInitialized
            }

            let client = try getClient(host: host)
            let defaultTimeout = CallOptions(timeLimit: .timeout(.seconds(10))) // TODO: configs

            var request = Sensory_Api_Oauth_TokenRequest()
            request.clientID = clientID
            request.secret = secret
            return client.getToken(request, callOptions: defaultTimeout).response
        } catch {
            return group.next().makeFailedFuture(error)
        }
    }

    func getClient(host: CloudHost) throws -> Sensory_Api_Oauth_OauthServiceClientProtocol {
        let channel = try GRPCChannelPool.with(
            target: .host(host.host, port: host.port),
            transportSecurity: host.isSecure ? .tls(GRPCTLSConfiguration.makeClientConfigurationBackedByNIOSSL()) : .plaintext,
            eventLoopGroup: group
        )

        return Sensory_Api_Oauth_OauthServiceClient(channel: channel)
    }
}
