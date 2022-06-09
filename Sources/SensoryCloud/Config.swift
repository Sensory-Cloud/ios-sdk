//
//  Config.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation

/// All configurations required to initialize the Sensory Cloud SDK
public struct SDKInitConfig: Codable {

    /// The authentication method required for device enrollment by the Sensory Cloud Server
    public enum EnrollmentType: String, Codable {
        /// No authentication required to enroll new devices
        case none
        /// Devices are enrolled via shared secretes (i.e. passwords)
        case sharedSecret
        /// Devices are enrolled via signed JWTs
        case jwt
    }

    /// The fully qualified domain name of the Sensory Cloud Server to communicate with
    var fullyQualifiedDomainName: String

    /// The tenant ID to use during device enrollment
    var tenantID: String

    /// The level of authentication required to enroll new devices into the Sensory Cloud Server
    ///
    ///  - Note: If the device has already been enrolled during a previous app session, this field is ignored
    var enrollmentType: EnrollmentType

    /// Credential for device enrollment
    ///
    /// Depending on the `enrollmentType` this may be blank, the shared secret, or the private key to create a JWT with
    ///  - Note: If the device has already been enrolled during a previous app session, this field is ignored
    var credential: String

    /// Unique identifier for the current device
    ///
    /// If this is left blank, the SDK will generate a device ID
    var deviceID: String?

    /// Name of the enrolling device
    ///
    /// If this is left blank, the system device name will be used
    var deviceName: String?

    /// Public initializer
    public init(
        _ fqdn: String,
        _ tenantID: String,
        _ enrollmentType: EnrollmentType,
        _ credential: String,
        _ deviceID: String? = nil,
        _ deviceName: String? = nil
    ) {
        self.fullyQualifiedDomainName = fqdn
        self.tenantID = tenantID
        self.enrollmentType = enrollmentType
        self.credential = credential
        self.deviceID = deviceID
        self.deviceName = deviceName
    }
}

/// Struct for providing info on a cloud host
public struct CloudHost: Equatable {
    /// Cloud DNS Host
    public var host: String
    /// Cloud port
    public var port: Int
    /// Says if the cloud host is setup for secure communication
    public var isSecure: Bool

    /// public initializer
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

    /// The cloud host that is used for grpc calls, this is set when `Initializer.initialize()` is called
    public internal(set) static var cloudHost: CloudHost?
    /// Tenant ID to use during device enrollment, this is set when `Initializer.initialize()` is called
    public internal(set) static var tenantID: String?
    /// Unique device identifier for the device, this is set when `Initializer.initialize()` is called
    public internal(set) static var deviceID: String?

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
    static func setCloudHost(host: String, port: Int = 443) {
        cloudHost = CloudHost(host, port, true)
    }

    /// Sets an insecure host for Sensory Cloud to use
    ///
    /// This should only be used for testing against a test cloud instance and not used in production
    /// - Parameters:
    ///   - host: Cloud host to use
    ///   - port: optional port, port 443 is used by default
    static func setInsecureCloudHost(host: String, port: Int = 443) {
        cloudHost = CloudHost(host, port, false)
    }

    /// Returns the currently configured cloud host, or `nil` if the SDK has not been initialized yet
    static func getCloudHost() -> CloudHost? {
        return cloudHost
    }
}
