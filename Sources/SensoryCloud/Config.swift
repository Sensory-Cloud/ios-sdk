//
//  Config.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation

public struct CloudHost: Equatable {
    public var host: String
    public var port: Int
    public var isSecure: Bool
}

public class Config {

    static var cloudHost: CloudHost?

    public static func setCloudHost(host: String, port: Int) {
        cloudHost = CloudHost(host: host, port: port, isSecure: true)
    }

    public static func setInsecureCloudHost(host: String, port: Int) {
        cloudHost = CloudHost(host: host, port: port, isSecure: false)
    }

    static func getCloudHost() -> CloudHost? {
        return cloudHost
    }
}
