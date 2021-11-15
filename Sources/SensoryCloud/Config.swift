//
//  Config.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation

/// Struct for providing info on a cloud host
public struct CloudHost: Equatable {
    /// Cloud DNS Host
    public var host: String
    /// Cloud port
    public var port: Int
    /// Says if the cloud host is setup for secure communication
    public var isSecure: Bool
}

/// Static class that provides configuration endpoints for Sensory Cloud
///
/// Configurations are not saved on device and must be set every time the app launches
public class Config {

    static var cloudHost: CloudHost?

    /// Sets the cloud host for Sensory Cloud to use
    /// - Parameters:
    ///   - host: Cloud host to use
    ///   - port: Optional port, port 443 is used by default
    public static func setCloudHost(host: String, port: Int = 443) {
        cloudHost = CloudHost(host: host, port: port, isSecure: true)
    }

    /// Sets an insecure host for Sensory Cloud to use
    ///
    /// This should only be used for testing against a test cloud instance and not used in production
    /// - Parameters:
    ///   - host: Cloud host to use
    ///   - port: optional port, port 443 is used by default
    public static func setInsecureCloudHost(host: String, port: Int = 443) {
        cloudHost = CloudHost(host: host, port: port, isSecure: false)
    }

    /// Returns the currently configured cloud host, or `nil` if a host has not been configured yet
    static func getCloudHost() -> CloudHost? {
        return cloudHost
    }
}
