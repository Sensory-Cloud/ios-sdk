//
//  MockCredentialProvider.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/10/21.
//

import Foundation
@testable import SensoryCloud

class MockCredentialProvider: CredentialProvider {

    var accessToken: String?
    var error: Error?

    func getAccessToken() throws -> String {
        if let token = accessToken {
            return token
        }
        throw error ?? NetworkError.notInitialized
    }

    func reset() {
        accessToken = nil
        error = nil
    }
}
