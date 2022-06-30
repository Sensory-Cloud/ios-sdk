//
//  EnvFileParser.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/10/22.
//

import Foundation

private enum SDKConfigKeys: String {
    case fqdn = "fullyQualifiedDomainName"
    case isSecure = "isSecure"
    case tenantID = "tenantID"
    case enrollmentType = "enrollmentType"
    case credential = "credential"
    case deviceID = "deviceID"
    case deviceName = "deviceName"
}

class EnvFileParser {

    private let truthyVals = ["true", "True", "TRUE", "T", "t", "yes", "Yes", "YES", "y", "Y", "1"]

    func loadConfig(fileURL: URL) throws -> SDKInitConfig {
        let fileContents = try String(contentsOf: fileURL)
        var contents: [String: String] = [:]
        for line in fileContents.components(separatedBy: "\n") {
            if !line.contains("=") {
                continue
            }

            let line = stripComment(line)
            let parts = line.split(separator: "=")
            if parts.count == 2 {
                let key = trim(String(parts[0]))
                let value = trim(String(parts[1]))
                contents[key] = value
            }
        }

        return try parseToConfig(contents: contents)
    }

    func trim(_ str: String) -> String {
        let whitespaces = CharacterSet(charactersIn: " \n\r\t\"")
        return str.trimmingCharacters(in: whitespaces)
    }

    func stripComment(_ line: String) -> String {
        let parts = line.split(
            separator: "#",
            maxSplits: 1,
            omittingEmptySubsequences: false)
        if parts.count > 0 {
            return String(parts[0])
        }
        return ""
    }

    func parseToConfig(contents: [String: String]) throws -> SDKInitConfig {
        let fqdn = try getValueFor(key: SDKConfigKeys.fqdn.rawValue, contents: contents)
        let isSecureStr = try getValueFor(key: SDKConfigKeys.isSecure.rawValue, contents: contents)
        let isSecure = truthyVals.contains(isSecureStr)
        let tenant = try getValueFor(key: SDKConfigKeys.tenantID.rawValue, contents: contents)
        let enrollmentTypeRaw = try getValueFor(key: SDKConfigKeys.enrollmentType.rawValue, contents: contents)
        let enrollmentType = SDKInitConfig.EnrollmentType(rawValue: enrollmentTypeRaw)
        guard let enrollmentType = enrollmentType else {
            throw InitializerError.invalidEnrollmentType(enrollmentTypeRaw)
        }
        let credential = try getValueFor(key: SDKConfigKeys.credential.rawValue, contents: contents)
        let deviceID = contents[SDKConfigKeys.deviceID.rawValue]
        let deviceName = contents[SDKConfigKeys.deviceName.rawValue]

        return SDKInitConfig(fqdn, isSecure, tenant, enrollmentType, credential, deviceID, deviceName)
    }

    func getValueFor(key: String, contents: [String: String]) throws -> String {
        return try contents[key] ?? throwMissingConfig(key: key)
    }

    func throwMissingConfig(key: String) throws -> String {
        throw InitializerError.missingConfig(key)
    }
}
