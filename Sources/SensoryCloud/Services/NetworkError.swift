//
//  NetworkError.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation

/// Various network errors that may occur
public enum NetworkError: Error {
    /// This occurs if the cloud host is not set before attempting to make a network call
    case notInitialized
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch  self {
        case .notInitialized:
            return "No saved server URL was found"
        }
    }
}
