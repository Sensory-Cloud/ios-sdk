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

        var expectedHost = CloudHost(host: "SecureHost", port: 444, isSecure: true)
        Config.setCloudHost(host: "SecureHost", port: 444)
        XCTAssertEqual(Config.cloudHost, expectedHost)
        XCTAssertEqual(Config.getCloudHost(), expectedHost)

        expectedHost = CloudHost(host: "AnotherSecureHost", port: 443, isSecure: true)
        Config.setCloudHost(host: "AnotherSecureHost")
        XCTAssertEqual(Config.cloudHost, expectedHost)
        XCTAssertEqual(Config.getCloudHost(), expectedHost)
    }

    func testSetInsecureCloudHost() throws {
        XCTAssertNil(Config.getCloudHost(), "Cloud host should initially be nil")

        var expectedHost = CloudHost(host: "SomeInsecureHost", port: 123, isSecure: false)
        Config.setInsecureCloudHost(host: "SomeInsecureHost", port: 123)
        XCTAssertEqual(Config.cloudHost, expectedHost)
        XCTAssertEqual(Config.getCloudHost(), expectedHost)

        expectedHost = CloudHost(host: "localhost", port: 443, isSecure: false)
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
