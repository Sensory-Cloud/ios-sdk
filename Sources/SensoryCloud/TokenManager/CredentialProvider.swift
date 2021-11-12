//
//  CredentialProvider.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/5/21.
//

import Foundation

public protocol CredentialProvider {
    func getAccessToken() throws -> String
}

extension TokenManager: CredentialProvider {}
