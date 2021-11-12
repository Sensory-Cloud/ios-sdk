//
//  NetworkError.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/4/21.
//

import Foundation

public enum NetworkError: Error {
    case notInitialized
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
