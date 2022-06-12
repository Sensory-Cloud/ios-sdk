//
//  InitializerError.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/10/22.
//

import Foundation

/// Error cases that may occur during SDK initialization
public enum InitializerError: Error {
    /// The specified SDK config file could not be found
    case configFileNotFound
    /// An error occurred while parsing the server fully qualified domain name
    case fqdnParseError
    /// An error for a missing configuration in the config file
    case missingConfig(String)
    /// An error for an invalid enrollment type
    case invalidEnrollmentType(String)
}

extension InitializerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .configFileNotFound:
            return "The config file could not be found"
        case .fqdnParseError:
            return "The fqdn could not be parsed"
        case .missingConfig(let key):
            return "Configuration for `\(key)` is missing from config file"
        case .invalidEnrollmentType(let key):
            return "Invalid enrollment type: `\(key)`. Expected `none`, `sharedSecret`, or `jwt`"
        }
    }
}
