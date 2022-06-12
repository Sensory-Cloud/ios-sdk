//
//  MockTokenManager.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/11/22.
//

import Foundation
@testable import SensoryCloud

class MockTokenManager: TokenManager {

    var credentials: AccessTokenCredentials?
    var mockHasCredentials = false
    var accessToken: String?

    var generateError: Error?
    var getError: Error?
    var deleteError: Error?
    var renewError: Error?

    func reset() {
        credentials = nil
        mockHasCredentials = false
        accessToken = nil
        generateError = nil
        getError = nil
        deleteError = nil
        renewError = nil
    }

    override func generateCredentials() throws -> AccessTokenCredentials {
        if let creds = credentials {
            return creds
        }
        throw generateError ?? KeychainError.expired
    }

    override func hasSavedCredentials() -> Bool {
        return mockHasCredentials
    }

    override func getAccessToken() throws -> String {
        if let token = accessToken {
            return token
        }
        throw getError ?? KeychainError.expired
    }

    override func deleteCredentials() -> Error? {
        return deleteError
    }

    override func renewDeviceCredential(credential: String) -> Error? {
        return renewError
    }
}
