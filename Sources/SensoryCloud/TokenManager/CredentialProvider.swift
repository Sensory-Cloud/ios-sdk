//
//  CredentialProvider.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/5/21.
//

import Foundation

/// Protocol for an object that can provide OAuth tokens to Sensory Cloud
///
/// `TokenManager` already conforms to this protocol and is used by default if `Service.credentialProvider` is not changed
/// Clients may use their own token management if they desire. These token managers would be responsible for:
///  - Generating their own clientIDs and client secrets
///    - clientIDs should be a UUID
///    - client secrets should be at least 10 hexadecimal characters that are generated in a cryptographically secure way
///  - Storing these credentials as well as any requested access tokens in a secure way (i.e. Apple Keychain)
///  - Requesting new access tokens and refreshing the access token when they expire
///    - `OAuthService` provides the grpc calls to request new tokens
///  - Setting `Service.credentialProvider` with their token management solution
public protocol CredentialProvider {

    /// Provides a valid OAuth token
    ///
    /// This call may block the current thread if a new token needs to be requested
    /// - Returns: A valid OAuth token
    func getAccessToken() throws -> String
}

extension TokenManager: CredentialProvider {}
