//
//  EnvFileParserTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/11/22.
//

import XCTest
@testable import SensoryCloud

// Test resources lose their directory structure when copied to the test bundle :(
private let filePrefix = "EnvFileParser_"

class EnvFileParserTests: XCTestCase {

    let parser = EnvFileParser()

    func testLoadConfig() throws {
        // Full config file
        guard let configURL = loadFile(named: "config", ext: "env") else {
            XCTFail("Couldn't load test file")
            return
        }
        var config = try parser.loadConfig(fileURL: configURL)
        var expected = SDKInitConfig("fqdn", true, "tenant", .none, "credential", "deviceID", "deviceName")
        XCTAssertEqual(config, expected)

        // Nil device info
        guard let noDeviceURL = loadFile(named: "noDevice", ext: "env") else {
            XCTFail("Couldn't load test file")
            return
        }
        config = try parser.loadConfig(fileURL: noDeviceURL)
        expected = SDKInitConfig("fqdn", true, "tenant", .sharedSecret, "credential")
        XCTAssertEqual(config, expected)

        // missing required config field
        guard let missingConfigURL = loadFile(named: "missingConfig", ext: "env") else {
            XCTFail("Couldn't load test file")
            return
        }
        XCTAssertThrowsError(try parser.loadConfig(fileURL: missingConfigURL))

        // invalid enrollment type
        guard let enrollmentTypeURL = loadFile(named: "badEnrollmentType", ext: "env") else {
            XCTFail("Couldn't load test file")
            return
        }
        XCTAssertThrowsError(try parser.loadConfig(fileURL: enrollmentTypeURL))
    }

    func loadFile(named: String, ext: String? = nil) -> URL? {
        return Bundle.module.url(forResource: filePrefix + named, withExtension: ext)
    }
}
