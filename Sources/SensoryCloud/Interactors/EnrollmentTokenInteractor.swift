//
//  EnrollmentTokenInteractor.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/9/22.
//

import Foundation

/// Class used to securely save and manage enrollment tokens
public class EnrollmentTokenInteractor {

    var persistence: KeychainPersistence

    private let tokenSuffix = "-token"
    private let expirationSuffix = "-expiration"

    /// Initializes a new instance of `EnrollmentTokenInteractor`
    public init() {
        self.persistence = KeychainPersistence()
    }

    /// Initializes `EnrollmentTokenInteractor` with a different persistence, used for unit testing
    init(persistence: KeychainPersistence) {
        self.persistence = persistence
    }

    /// Securely saves a new enrollment token for the given enrollment ID
    ///
    /// If a token is already saved to the enrollment ID, the previous token will be deleted
    /// - Parameters:
    ///   - enrollmentID: enrollment ID of the token to save
    ///   - token: Enrollment Token object returned by the Sensory Cloud server
    public func saveEnrollmentToken(enrollmentID: String, token: Sensory_Api_Common_EnrollmentToken) throws {
        try deleteEnrollmentToken(enrollmentID: enrollmentID)

        try persistence.save(id: enrollmentID + tokenSuffix, data: token.token)

        if token.expiration > 0 {
            let expiration = Date().timeIntervalSince1970 + Double(token.expiration)
            let expirationData = withUnsafeBytes(of: expiration) { Data($0) }
            try persistence.save(id: enrollmentID + expirationSuffix, data: expirationData)
        }
    }

    /// Retrieves a saved enrollment token from secure storage
    ///
    /// If no token is found for the given enrollmentID, nil will be returned and no error will be thrown
    /// - Parameter enrollmentID: The enrollment ID to get the enrollment token for
    /// - Returns: The saved enrollment token, or nil if no token was found
    public func getEnrollmentToken(enrollmentID: String) throws -> Data? {
        var token: Data
        var expirationData: Data

        do {
            token = try persistence.getData(id: enrollmentID + tokenSuffix)
        } catch KeychainError.itemNotFound {
            // Return nil instead of throwing an error if no token was ever saved
            return nil
        } catch {
            throw error
        }

        do {
            expirationData = try persistence.getData(id: enrollmentID + expirationSuffix)
        } catch KeychainError.itemNotFound {
            // token has no expiration
            return token
        } catch {
            throw error
        }

        let expiration = expirationData.withUnsafeBytes { $0.load(as: Double.self) }
        let now = Date().timeIntervalSince1970

        if now > expiration {
            try deleteEnrollmentToken(enrollmentID: enrollmentID)
            throw KeychainError.expired
        }

        return token
    }

    /// Deletes a saved enrollment token
    ///
    /// No error is thrown if the enrollment token was not found in the secure storage
    /// - Parameter enrollmentID: The enrollment ID of the token to delete
    public func deleteEnrollmentToken(enrollmentID: String) throws {
        try persistence.delete(id: enrollmentID + tokenSuffix)
        try persistence.delete(id: enrollmentID + expirationSuffix)
    }
}
