//
//  Service.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation
import GRPC
import NIOHPACK

// Shared superclass for all of the grpc clients from the auto-generated code
protocol GrpcClient {
    init(grpcChannel: GRPCChannel)
}

/// Overall Service class which maintains an in memory cache of various network elements and
/// shared logic for creating clients and attaching OAuth tokens to server calls.
public class Service {

    /// Persistence for storing + loading access tokens from
    ///
    /// This variable defaults to a new instance of `TokenManager`. This variable may be set to allow for clients to manage their own OAuth credentials.
    public var credentialProvider: CredentialProvider = TokenManager()

    /// Static event loop group which is shared between all services
    let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)

    /// Cloud host used for the current cached clients
    var cacheHost: CloudHost?

    /// Cached grpc clients used by service subclasses
    var cachedClients: [String: Any] = [:]

    init() {}

    /// Shared service instance, This should only be used for setting a non-default `credentialProvider`
    public static let shared = Service()

    /// Returns a cached grpc client of the specified type, or creates and caches a new one
    ///
    /// - Throws: Any errors encountered while establishing the client connection
    func getClient<T: GrpcClient>() throws -> T {

        // Check if the cache is still valid
        if cacheHost != Config.getCloudHost() || cacheHost == nil {
            cachedClients.removeAll()
            cacheHost = Config.getCloudHost()
        }

        // Check for a cached client
        let key = "\(T.self)"
        if let client = cachedClients[key] as? T {
            return client
        }

        // Create a new client and add it to the cache
        let channel = try getGRPCChannel()
        let client = T.init(grpcChannel: channel)
        cachedClients[key] = client
        return client
    }

    /// Creates a new grpc channel
    ///
    /// - Throws: NetworkError.notInitialized if a cloud host has not been set, or any error encountered while creating the grpc channel
    func getGRPCChannel() throws -> GRPCChannel {
        guard let host = Config.getCloudHost() else {
            throw NetworkError.notInitialized
        }

        return try GRPCChannelPool.with(
            target: .host(host.host, port: host.port),
            transportSecurity: host.isSecure ? .tls(GRPCTLSConfiguration.makeClientConfigurationBackedByNIOSSL()) : .plaintext,
            eventLoopGroup: group
        )
    }

    /// Creates the default metadata that should be attached to all grpc calls
    ///
    /// - Parameter isUnary: Unary grpc calls have a default timeout which should not be applied to streaming calls
    /// - Throws: Any error encountered while generating an OAuth token
    func getDefaultMetadata(isUnary: Bool = false) throws -> CallOptions {
        let token = try credentialProvider.getAccessToken()
        let headers: HPACKHeaders = ["authorization": "Bearer \(token)"]
        if isUnary {
            return CallOptions(customMetadata: headers, timeLimit: .timeout(.seconds(Config.grpcTimeout)))
        } else {
            return CallOptions(customMetadata: headers)
        }
    }
}
