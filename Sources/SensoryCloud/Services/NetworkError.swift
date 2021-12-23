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
    /// This is an internal error that occurs if the grpc server client class cannot be found
    case invalidClientClass(String)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch  self {
        case .notInitialized:
            return "No saved server URL was found"
        case .invalidClientClass(let className):
            return "Expected a grpc 'ClientProtocol' class, received: \(className)"
        }
    }
}
