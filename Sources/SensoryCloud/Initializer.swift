//
//  Initializer.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/2/22.
//

import Foundation
import UIKit

public typealias SDKinitResult = Result<Sensory_Api_V1_Management_DeviceResponse?, Error>
public typealias SDKinitCallback = (SDKinitResult) -> Void

public class Initializer {

    public static var oauthService = OAuthService()
    public static var tokenManager = TokenManager()

    // static class
    private init() {}

    /// Initializes the Sensory Cloud SDK
    ///
    /// This will load SDK configurations from a config file and will automatically register the device with Sensory Cloud
    /// - Parameter configFile: A file URL to the SDK configuration file. If nil, the SDK will check the main bundle for a "config.json" file
    public static func initialize(configFile: URL? = nil, completion: @escaping SDKinitCallback) {
        // TODO: ini/env files
        guard let fileURL = configFile ?? Bundle.main.url(forResource: "config", withExtension: "json") else {
            completion(.failure(InitializationError.configFileNotFound))
            return
        }

        do {
            let config = try loadConfig(fileURL: fileURL)
            initialize(config: config, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    public static func initialize(config: SDKInitConfig, completion: @escaping SDKinitCallback) {

        // Save config in memory
        guard let host = parseURL(config.fullyQualifiedDomainName) else {
            completion(.failure(InitializationError.fqdnParseError))
            return
        }
        Config.tenantID = config.tenantID
        Config.deviceID = config.deviceID ?? UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        if host.isSecure {
            Config.setCloudHost(host: host.host, port: host.port)
        } else {
            Config.setInsecureCloudHost(host: host.host, port: host.port)
        }

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
            // TODO: JWT support
            NSLog("JWT enrollments not currently supported")
            completion(.failure(InitializationError.configFileNotFound))
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
            NSLog("Login Failure")
            unsetConfigChanges()
            let delErr = tokenManager.deleteCredentials()
            if delErr != nil {
                NSLog("Failed to delete oauth credentials: %@", delErr?.localizedDescription ?? "no description")
            }
            completion(.failure(error))
        }
    }

    private static func loadConfig(fileURL: URL) throws -> SDKInitConfig {
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let jsonData = try decoder.decode(SDKInitConfig.self, from: data)
        return jsonData
    }

    private static func unsetConfigChanges() {
        Config.tenantID = nil
        Config.deviceID = nil
        Config.setCloudHost(host: "")
    }
}
