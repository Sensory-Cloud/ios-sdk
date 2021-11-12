//
//  OAuthService.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/3/21.
//

import Foundation
import GRPC
import NIO

// TODO: better integration w/ service

/// Service responsible for requesting new OAuth tokens
///
/// - NOTE: This class is not a subclass of `Service` to prevent a circular dependency between `OAuthService` and `OAuthPersistence`
public class OAuthService {

    // TODO: share this w/ service
    let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

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

            let client: Sensory_Api_Oauth_OauthServiceClient = getClient(host: host)
            let defaultTimeout = CallOptions(timeLimit: .timeout(.seconds(10))) // TODO: configs

            var request = Sensory_Api_Oauth_TokenRequest()
            request.clientID = clientID
            request.secret = secret
            return client.getToken(request, callOptions: defaultTimeout).response
        } catch {
            return group.next().makeFailedFuture(error)
        }
    }

    // TODO: share this w/ service
    func getClient(host: CloudHost) -> Sensory_Api_Oauth_OauthServiceClient {
        var connection: ClientConnection
        if host.isSecure {
            connection = ClientConnection.secure(group: group).connect(host: host.host, port: host.port)
        } else {
            connection = ClientConnection.insecure(group: group).connect(host: host.host, port: host.port)
        }

        return Sensory_Api_Oauth_OauthServiceClient(channel: connection)
    }
}
