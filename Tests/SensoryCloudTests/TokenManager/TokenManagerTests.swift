//
//  TokenManagerTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/8/21.
//

import XCTest
@testable import SensoryCloud

final class TokenManagerTests: XCTestCase {

    var mockService = MockOAuthService()
    var mockKeychain = MockKeychainPersistence()

    override func setUp() {
        mockKeychain.reset()
        mockService.reset()
    }

    func testGenerateCredentials() throws {

        let manager = TokenManager(service: mockService, keychain: mockKeychain)

        var prevIDs: [String] = []
        var prevSecrets: [String] = []

        for _ in 1...100 {
            let credential = try manager.generateCredentials()

            XCTAssertEqual(credential.clientID, try mockKeychain.getString(id: TokenManager.KeychainTag.clientID))
            XCTAssertEqual(credential.secret, try mockKeychain.getString(id: TokenManager.KeychainTag.clientSecret))
            XCTAssert(UUID(uuidString: credential.clientID) != nil, "Client ID should be a UUID")
            XCTAssertEqual(credential.secret.count, 15, "client secret should be 15 characters")
            XCTAssertFalse(prevIDs.contains(credential.clientID), "duplicate IDs should be avoided")
            XCTAssertFalse(prevSecrets.contains(credential.secret), "duplicate secrets should be avoided")
            prevIDs.append(credential.clientID)
            prevSecrets.append(credential.secret)
        }
    }

    func testHasSavedCredentials() throws {
        let manager = TokenManager(service: mockService, keychain: mockKeychain)

        XCTAssertFalse(manager.hasSavedCredentials())

        try mockKeychain.save(id: TokenManager.KeychainTag.clientSecret, string: "secret")
        XCTAssertFalse(manager.hasSavedCredentials())

        try mockKeychain.save(id: TokenManager.KeychainTag.clientID, string: "clientID")
        XCTAssertTrue(manager.hasSavedCredentials())
    }

    func testGetAccessToken() throws {
        let manager = TokenManager(service: mockService, keychain: mockKeychain)

        // Test w/o saved credentials
        do {
            _ = try manager.getAccessToken()
            XCTFail("Getting access token should fail when there are no credentials")
        } catch KeychainError.itemNotFound(_) {
            // Expected error case
        } catch {
            XCTFail("Expected item not found error: \(error.localizedDescription)")
        }

        // Test w/o cached OAuth token
        var response = Sensory_Api_Common_TokenResponse()
        response.accessToken = "mockAccessToken"
        response.expiresIn = 600
        mockService.response = response
        let credentials = try manager.generateCredentials()
        let token = try manager.getAccessToken()
        var now = Date().timeIntervalSince1970

        XCTAssertEqual(mockService.clientID, credentials.clientID)
        XCTAssertEqual(mockService.secret, credentials.secret)
        XCTAssertEqual(response.accessToken, token)
        XCTAssertEqual(token, try mockKeychain.getString(id: TokenManager.KeychainTag.accessToken))
        var expirationData = try mockKeychain.getData(id: TokenManager.KeychainTag.expiration)
        var expiration = expirationData.withUnsafeBytes { $0.load(as: Double.self) }
        var diff = expiration - (now + 600)
        XCTAssertTrue(abs(diff) < 1)

        // Test w/ cached OAuth token
        mockService.reset()
        var newToken = try manager.getAccessToken()

        XCTAssertEqual(newToken, token, "cached access token should be used")
        XCTAssertNil(mockService.clientID, "OAuth service should not be queried when there is a cached access token")

        // Test w/ expired cached OAuth token
        let newExpiration: Double = 0
        try mockKeychain.save(id: TokenManager.KeychainTag.expiration, data: withUnsafeBytes(of: newExpiration) { Data($0) })
        response = Sensory_Api_Common_TokenResponse()
        response.accessToken = "NewAccessToken"
        response.expiresIn = 600
        mockService.response = response
        newToken = try manager.getAccessToken()
        now = Date().timeIntervalSince1970

        XCTAssertEqual(newToken, response.accessToken)
        XCTAssertEqual(mockService.clientID, credentials.clientID)
        expirationData = try mockKeychain.getData(id: TokenManager.KeychainTag.expiration)
        expiration = expirationData.withUnsafeBytes { $0.load(as: Double.self) }
        diff = expiration - (now + 600)
        XCTAssertTrue(abs(diff) < 1)
    }

    func testDeleteCredentials() throws {
        let manager = TokenManager(service: mockService, keychain: mockKeychain)

        XCTAssertNil(manager.deleteCredentials(), "Delete credentials should not fail when there are no credentials")

        _ = try manager.generateCredentials()
        XCTAssertNil(manager.deleteCredentials())
        XCTAssertFalse(manager.hasSavedCredentials())
    }
}
