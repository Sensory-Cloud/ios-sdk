//
//  TokenManager.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/3/21.
//

import Foundation

/// A wrapper struct for OAuth token credentials
public struct AccessTokenCredentials {
    /// The OAuth client id
    public var clientID: String

    /// The OAuth client secret
    public var secret: String
}

/// A token manager class that may be used for managing and securely storing OAuth credentials for Sensory Cloud.
///
/// Once credentials have been generated, `TokenManager` will automatically provide access tokens to the Sensory Cloud services
/// See the documentation for `CredentialProvider` for instructions on providing your own token management for Sensory Cloud
public class TokenManager {

    enum KeychainTag {
        static let clientID = "Sensory_Client_ID"
        static let clientSecret = "Sensory_Client_Secret"
        static let accessToken = "Access_Token"
        static let expiration = "Expiration"
    }

    private static let group = DispatchGroup()

    private let tokenExpirationBuffer: TimeInterval = 300 // 5 minutes

    private let service: OAuthService
    private let keychain: KeychainPersistence

    init(service: OAuthService, keychain: KeychainPersistence) {
        self.service = service
        self.keychain = keychain
    }

    /// Initializes a new instance of `TokenManager`.
    /// Stored OAuth credentials are statically shared between different instances of `TokenManger`
    public init() {
        self.service = OAuthService()
        self.keychain = KeychainPersistence()
    }

    /// Generates and stores new set of OAuth credentials
    ///
    /// This function will overwrite any other credentials that have been generated using this function
    /// - Throws: An error if credentials cannot be securely generated or if the credentials cannot be stored in the Apple Keychain
    /// - Returns: The generated OAuth credentials
    public func generateCredentials() throws -> AccessTokenCredentials {
        let clientID = UUID().uuidString
        let secret = try secRandomString(length: 15)

        try keychain.save(id: KeychainTag.clientID, string: clientID)
        try keychain.save(id: KeychainTag.clientSecret, string: secret)

        return AccessTokenCredentials(clientID: clientID, secret: secret)
    }

    /// Determines if any credentials are stored on device
    ///
    /// - Returns: `True` if any credentials are found
    public func hasSavedCredentials() -> Bool {
        do {
            try _ = keychain.getString(id: KeychainTag.clientID)
            try _ = keychain.getString(id: KeychainTag.clientSecret)
            return true
        } catch KeychainError.itemNotFound {
            return false
        } catch {
            NSLog("An error occurred while reading OAuth credentials: %@", error.localizedDescription)
            return false
        }
    }

    /// Returns a valid access token for Sensory Cloud grpc calls
    ///
    /// This function will immediately return if the cached access token is still valid. If a new token needs to
    /// be requested, this function will block on the current thread until a new token has been fetched from the server.
    /// - Throws: An error if one occurs while retrieving the saved token, or if an error occurs while requesting a new one
    /// - Returns: A valid access token
    public func getAccessToken() throws -> String {

        // Prevent multiple access tokens from being requested at the same time
        Self.group.wait()
        Self.group.enter()
        defer { Self.group.leave() }

        var accessToken: String, expirationData: Data

        do {
            try accessToken = keychain.getString(id: KeychainTag.accessToken)
            try expirationData = keychain.getData(id: KeychainTag.expiration)
        } catch KeychainError.itemNotFound {
            NSLog("Could not find saved access token, fetching new token")
            return try fetchNewAccessToken()
        } catch {
            throw error
        }

        let expiration = expirationData.withUnsafeBytes { $0.load(as: Double.self) }
        let now = Date().timeIntervalSince1970

        if now > expiration - tokenExpirationBuffer {
            NSLog("Cached access token has expired, requesting new token")
            return try fetchNewAccessToken()
        }

        NSLog("Returning cached access token")
        return accessToken
    }

    /// Deletes any credentials stored for requesting access tokens, as well as any cached access tokens on device
    ///
    /// - Returns: An error if one occurs during deletion
    public func deleteCredentials() -> Error? {
        do {
            try keychain.delete(id: KeychainTag.accessToken)
            try keychain.delete(id: KeychainTag.expiration)
            try keychain.delete(id: KeychainTag.clientID)
            try keychain.delete(id: KeychainTag.clientSecret)
            return nil
        } catch {
            return error
        }
    }

    /// Fetches a new access token from a remote server
    private func fetchNewAccessToken() throws -> String {
        let clientID = try keychain.getString(id: KeychainTag.clientID)
        let secret = try keychain.getString(id: KeychainTag.clientSecret)

        let rsp = service.getToken(clientID: clientID, secret: secret)
        let result = try rsp.wait()

        try keychain.save(id: KeychainTag.accessToken, string: result.accessToken)
        let expiration = Date().timeIntervalSince1970 + Double(result.expiresIn)
        let expirationData = withUnsafeBytes(of: expiration) { Data($0) }
        try keychain.save(id: KeychainTag.expiration, data: expirationData)

        return result.accessToken
    }

    /// Generates a cryptographically secure hex string of the specified length
    private func secRandomString(length: Int) throws -> String {
        // Generate a random bytes array
        let numBytes = Int(ceil(Double(length)/2))
        var bytes = [Int8](repeating: 0, count: numBytes)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status != errSecSuccess {
            throw KeychainError.insecureRandom
        }

        // Convert to hex string
        let str = bytes.map { String(format: "%02hhX", $0) }.joined()
        return String(str.prefix(length))
    }
}
