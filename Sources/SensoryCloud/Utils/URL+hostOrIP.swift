//
//  URL+hostOrIP.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/3/22.
//

import Foundation

/// Quick regex for an ip address with an optional port attached
private let ipAndPortRegex = "^(\\d+\\.){3}\\d+(:\\d+)?$"
/// Default Server port if not otherwise specified
private let defaultPort = 443

/// Parses a raw url string into a Sensory Cloud host
///
/// - Parameter urlStr: raw url string to parse
/// - Returns: Parsed cloud host, or nil if the url cannot be parsed
func parseURL(_ urlStr: String, _ isSecure: Bool = true) -> CloudHost? {
    guard let url = URL(string: urlStr) else {
        return nil
    }
    guard let host = url.hostOrIP else {
        return nil
    }
    let port = url.ipSafePort ?? defaultPort
    return CloudHost(host, port, isSecure)
}

/// Some of the automatic host and port parsing provided by `URL` breaks if the url is a raw ip + port combination Ex: `127.0.0.1:9001`
/// This extension aims to add support for such urls
/// - Note: this extension does not handle `localhost`. `127.0.0.1` should be used instead
extension URL {

    /// Returns the automatically parsed host, or the ip address if the url is a raw ip + port
    var hostOrIP: String? {
        if let host = host {
            return host
        }

        if scheme != nil {
            return nil
        }

        return URL(string: "https://\(absoluteString)").flatMap { $0.host }
    }

    /// Returns the port if specified. This will handle standard urls and raw ip + port combinations
    var ipSafePort: Int? {
        if let port = port {
            return port
        }

        if scheme != nil {
            return nil
        }

        return URL(string: "https://\(absoluteString)").flatMap { $0.port }
    }
}
