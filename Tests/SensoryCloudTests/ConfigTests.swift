//
//  ConfigTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/12/21.
//

import XCTest
@testable import SensoryCloud

final class ConfigTests: XCTestCase {

    override func setUp() {
        Config.cloudHost = nil
        Config.jpegCompression = 0.5
    }

    func testSetCloudHost() throws {
        XCTAssertNil(Config.getCloudHost(), "Cloud host should initially be nil")

        var expectedHost = CloudHost("SecureHost", 444, true)
        Config.setCloudHost(host: "SecureHost", port: 444)
        XCTAssertEqual(Config.cloudHost, expectedHost)
        XCTAssertEqual(Config.getCloudHost(), expectedHost)

        expectedHost = CloudHost("AnotherSecureHost", 443, true)
        Config.setCloudHost(host: "AnotherSecureHost")
        XCTAssertEqual(Config.cloudHost, expectedHost)
        XCTAssertEqual(Config.getCloudHost(), expectedHost)
    }

    func testSetInsecureCloudHost() throws {
        XCTAssertNil(Config.getCloudHost(), "Cloud host should initially be nil")

        var expectedHost = CloudHost("SomeInsecureHost", 123, false)
        Config.setInsecureCloudHost(host: "SomeInsecureHost", port: 123)
        XCTAssertEqual(Config.cloudHost, expectedHost)
        XCTAssertEqual(Config.getCloudHost(), expectedHost)

        expectedHost = CloudHost("localhost", 443, false)
        Config.setInsecureCloudHost(host: "localhost")
        XCTAssertEqual(Config.cloudHost, expectedHost)
        XCTAssertEqual(Config.getCloudHost(), expectedHost)
    }

    func testJpegCompression() throws {
        Config.jpegCompression = 1.5
        XCTAssertEqual(1, Config.jpegCompression)

        Config.jpegCompression = -5
        XCTAssertEqual(0, Config.jpegCompression)
    }
}
