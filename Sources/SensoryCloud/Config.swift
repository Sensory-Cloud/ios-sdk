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

    public init(_ host: String, _ port: Int, _ isSecure: Bool) {
        self.host = host
        self.port = port
        self.isSecure = isSecure
    }
}

/// Static class that provides configuration endpoints for Sensory Cloud
///
/// Configurations are not saved on device and must be set every time the app launches
public class Config {

    static var cloudHost: CloudHost?
    /// Tenant ID to use during device enrollment
    public static var tenantID: String?
    /// Unique device identifier that model enrollments are associated to
    public static var deviceID: String?

    /// Supported sample rate for audio models (16kHz)
    public static let audioSampleRate: Float64 = 16000

    /// Photo pixel height, defaults to 720 pixels
    public static var photoHeight = 720
    /// Photo pixel width, defaults to 480 pixels
    public static var photoWidth = 480
    /// Jpeg Compression factor used, a value between 0 and 1 where 0 is most compressed, and 1 is highest quality
    public static var jpegCompression: Double = 0.5 {
        didSet {
            if jpegCompression > 1 {
                jpegCompression = 1
            }
            if jpegCompression < 0 {
                jpegCompression = 0
            }
        }
    }

    /// User's preferred language/region code (ex: en-US, used for audio enrollments. Defaults to the system Locale
    public static var languageCode: String = "\(Locale.current.languageCode ?? "en")-\(Locale.current.regionCode ?? "US")"

    /// Number of seconds to wait on a unary grpc call before timing out, defaults to 10 seconds.
    public static var grpcTimeout: Int64 = 10

    /// Sets the cloud host for Sensory Cloud to use
    /// - Parameters:
    ///   - host: Cloud host to use
    ///   - port: Optional port, port 443 is used by default
    public static func setCloudHost(host: String, port: Int = 443) {
        cloudHost = CloudHost(host, port, true)
    }

    /// Sets an insecure host for Sensory Cloud to use
    ///
    /// This should only be used for testing against a test cloud instance and not used in production
    /// - Parameters:
    ///   - host: Cloud host to use
    ///   - port: optional port, port 443 is used by default
    public static func setInsecureCloudHost(host: String, port: Int = 443) {
        cloudHost = CloudHost(host, port, false)
    }

    /// Returns the currently configured cloud host, or `nil` if a host has not been configured yet
    static func getCloudHost() -> CloudHost? {
        return cloudHost
    }
}
