//
//  KeychainError.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/3/21.
//

import Foundation

/// Various errors that may occur while interacting with the Apple Keychain
public enum KeychainError: Error {
    /// An error that occurs while saving to Apple Keychain, the specific OSStatus is attached if available
    case saveError(OSStatus?)
    /// An error that occurs while fetching from the Apple Keychain, the specific OSStatus is attached if available
    case getError(OSStatus?)
    /// This occurs if something cannot be found in the Apple Keychain, the tag queried for is attached
    case itemNotFound(String)
    /// An error that occurs while deleting from the Apple Keychain, the specific OSStatus is attached if available
    ///
    /// In general, deleting an item that does not exist is *NOT* considered as an error case
    case deleteError(OSStatus?)
    /// An error that occurs while encoding data before storing it in Apple Keychain
    case encodingError
    /// An error that occurs while decoding data from Apple Keychain
    case decodingError
    /// An error that occurs if the device isn't able to generate cryptographically secure random numbers
    case insecureRandom
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
        case .insecureRandom:
            return "Cryptographically secure random numbers cannot be generated"
        }
    }
}

/// Helper util for `SecCopyErrorMessageString`
public extension OSStatus {
    /// Generates an error message using `SecCopyErrorMessageString` and converts the result to a string
    var secErrDescription: String? {
        return SecCopyErrorMessageString(self, nil).map { String($0) }
    }
}
