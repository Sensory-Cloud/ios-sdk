//
//  URL+hostORIP.swift
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
func parseURL(_ urlStr: String) -> CloudHost? {
    guard let url = URL(string: urlStr) else {
        return nil
    }
    guard let host = url.hostOrIP else {
        return nil
    }
    let port = url.ipSafePort ?? defaultPort
    let secure = url.isSecure
    return CloudHost(host, port, secure)
}

/// Some of the automatic host and port parsing provided by `URL` breaks if the url is a raw ip + port combination Ex: `127.0.0.1:9001`
/// This extension aims to add support for such urls
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

    /// Returns true if the url is a raw ip + port
    var isIP: Bool {
        return absoluteString.range(of: ipAndPortRegex, options: .regularExpression, range: nil, locale: nil) != nil
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

    /// Attempts to determine if TLS encryption should be used. This assumes that raw ip + port urls do not support TLS
    var isSecure: Bool {
        if let scheme = scheme {
            return scheme != "http"
        }

        // assume we're insecure if the url is a raw ip and port
        return !isIP
    }
}
