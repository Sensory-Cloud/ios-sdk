//
//  Initializer.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/2/22.
//

import Foundation
import UIKit

/// Result type for initializing the SDK. The success result will be nil if the device has been previously enrolled
public typealias SDKinitResult = Result<Sensory_Api_V1_Management_DeviceResponse?, Error>
/// Callback function for SDK initialization
public typealias SDKinitCallback = (SDKinitResult) -> Void

/// Static initialization class. The Sensory Cloud SDK *must* be initialized every time the app is launched.
public class Initializer {

    /// OAuth service used for device enrollment
    public static var oauthService = OAuthService()
    /// Token manager used for creating/storing OAuth credentials
    public static var tokenManager = TokenManager()

    // static class
    private init() {}

    /// Initializes the Sensory Cloud SDK from an initialization file
    ///
    /// This will load SDK configurations from a config file and will automatically register the device with Sensory Cloud
    /// - Parameter configFile: A file URL to the SDK configuration file. If nil, the SDK will check the main bundle for a "config.ini" file
    /// - Parameter completion: Completion handler called once the initialization is complete or when an error occurs
    public static func initialize(configFile: URL? = nil, completion: @escaping SDKinitCallback) {
        guard let fileURL = configFile ?? Bundle.main.url(forResource: "config", withExtension: "ini") else {
            completion(.failure(InitializerError.configFileNotFound))
            return
        }

        do {
            let config = try loadConfig(fileURL: fileURL)
            initialize(config: config, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    /// Initializes the Sensory Cloud SDK from an initialization object
    ///
    /// - Parameters:
    ///   - config: Configuration object to use to configure the Sensory Cloud SDK
    ///   - completion: Completion handler called once the initialization is complete or when an error occurs
    public static func initialize(config: SDKInitConfig, completion: @escaping SDKinitCallback) {

        // Save config in memory
        guard let host = parseURL(config.fullyQualifiedDomainName) else {
            completion(.failure(InitializerError.fqdnParseError))
            return
        }
        Config.tenantID = config.tenantID
        Config.deviceID = config.deviceID ?? UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        Config.setCloudHost(host: host.host, port: host.port, isSecure: config.isSecure)

        // check if the device is already enrolled
        if tokenManager.hasSavedCredentials() {
            completion(.success(nil))
            return
        }

        // generate oauth credentials
        let oauthCredentials: AccessTokenCredentials
        do {
            oauthCredentials = try tokenManager.generateCredentials()
        } catch {
            unsetConfigChanges()
            completion(.failure(error))
            return
        }

        // Assemble enrollment credential
        var credential: String = ""
        switch config.enrollmentType {
        case .none:
            break
        case .sharedSecret:
            credential = config.credential
        case .jwt:
            do {
                credential = try genJWT(
                    enrollmentKey: config.credential,
                    deviceName: config.deviceName ?? UIDevice.current.name,
                    tenantID: config.tenantID,
                    clientID: oauthCredentials.clientID
                )
            } catch {
                unsetConfigChanges()
                completion(.failure(error))
                return
            }
        }
        credential = config.credential

        // Enroll device
        let rsp = oauthService.enrollDevice(
            name: config.deviceName ?? UIDevice.current.name,
            credential: credential,
            clientID: oauthCredentials.clientID,
            clientSecret: oauthCredentials.secret
        )

        rsp.whenSuccess { result in
            completion(.success(result))
        }

        rsp.whenFailure { error in
            unsetConfigChanges()
            let delErr = tokenManager.deleteCredentials()
            if delErr != nil {
                NSLog("Failed to delete oauth credentials: %@", delErr?.localizedDescription ?? "no description")
            }
            completion(.failure(error))
        }
    }

    private static func loadConfig(fileURL: URL) throws -> SDKInitConfig {
        switch fileURL.pathExtension {
        case "json":
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(SDKInitConfig.self, from: data)
            return jsonData
        case "plist":
            let data = try Data(contentsOf: fileURL)
            let decoder = PropertyListDecoder()
            let plistData = try decoder.decode(SDKInitConfig.self, from: data)
            return plistData
        default:
            let decoder = EnvFileParser()
            let config = try decoder.loadConfig(fileURL: fileURL)
            return config
        }
    }

    private static func unsetConfigChanges() {
        Config.tenantID = nil
        Config.deviceID = nil
        Config.setCloudHost(host: "")
    }
}
