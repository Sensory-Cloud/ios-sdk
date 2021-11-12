//
//  KeychainError.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/3/21.
//

import Foundation

public enum KeychainError: Error {
    case saveError(OSStatus?)
    case getError(OSStatus?)
    case itemNotFound(String)
    case deleteError(OSStatus?)
    case encodingError
    case decodingError
}

extension KeychainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .saveError(let status):
            return "Could not save to Apple Keychain: \(status?.secErrDescription ?? "<nil>")"
        case .getError(let status):
            return "Could not load from Apple Keychain: \(status?.secErrDescription ?? "<nil>")"
        case .itemNotFound(let id):
            return "Could not locate data in Apple Keychain for id: \(id)"
        case .deleteError(let status):
            return "Could not delete from Apple Keychain: \(status?.secErrDescription ?? "<nil>")"
        case .encodingError:
            return "An error occurred while encoding a string to data"
        case .decodingError:
            return "An error occurred while decoding data to a string"
        }
    }
}

extension OSStatus {
    /// Wrapper variable around `SecCopyErrorMessageString` and converts the results from `CFString` to `String`
    var secErrDescription: String? {
        return SecCopyErrorMessageString(self, nil).map { String($0) }
    }
}
