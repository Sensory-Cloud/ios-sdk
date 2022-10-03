//
//  HealthService.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 3/13/22.
//

import Foundation
import NIOCore
import GRPC

extension Sensory_Api_Health_HealthServiceNIOClient: GrpcClient {
    init(grpcChannel: GRPCChannel) {
        self.init(channel: grpcChannel)
    }
}

/// A collection of grpc service calls for getting the health of the cloud health
public class HealthService {

    var service: Service

    /// Initializes a new instance of `HealthService`
    public init() {
        self.service = Service.shared
    }

    /// Fetches the current health status of the cloud host
    ///
    /// - Returns: A future to be fulfilled with either the server health, or a network error if one occurred
    public func getHealth() -> EventLoopFuture<Sensory_Api_Common_ServerHealthResponse> {
        do {
            let client: Sensory_Api_Health_HealthServiceNIOClient = try service.getClient()
            let defaultTimeout = CallOptions(timeLimit: .timeout(.seconds(Config.grpcTimeout)))

            return client.getHealth(Sensory_Api_Health_HealthRequest(), callOptions: defaultTimeout).response
        } catch {
            return service.group.next().makeFailedFuture(error)
        }
    }
}
