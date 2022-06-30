//
//  URL+hostOrIPTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/11/22.
//

import XCTest
@testable import SensoryCloud

class URL_hostOrIPTests: XCTestCase {

    func testParseURL() {
        var url = "https://testing.com"
        var expectedHost = CloudHost("testing.com", 443, true)
        XCTAssertEqual(parseURL(url), expectedHost)

        url = "http://website.net:1234"
        expectedHost = CloudHost("website.net", 1234, false)
        XCTAssertEqual(parseURL(url, false), expectedHost)

        url = "sensorycloud.ai"
        expectedHost = CloudHost("sensorycloud.ai", 443, true)
        XCTAssertEqual(parseURL(url), expectedHost)

        url = "127.0.0.1:800"
        expectedHost = CloudHost("127.0.0.1", 800, false)
        XCTAssertEqual(parseURL(url, false), expectedHost)

        // localhost is not supported
        url = "localhost:8001"
        XCTAssertNil(parseURL(url))

        url = "some bogus string"
        XCTAssertNil(parseURL(url))
    }

    func testHostOrIP() {
        var url = URL(string: "https://google.com")!
        XCTAssertEqual(url.hostOrIP, "google.com")

        url = URL(string: "yahoo.com")!
        XCTAssertEqual(url.hostOrIP, "yahoo.com")

        url = URL(string: "127.0.0.1:1000")!
        XCTAssertEqual(url.hostOrIP, "127.0.0.1")
    }

    func testIPSafePort() {
        var url = URL(string: "google.com")!
        XCTAssertNil(url.ipSafePort)

        url = URL(string: "https://google.com:443")!
        XCTAssertEqual(url.ipSafePort, 443)

        url = URL(string: "127.0.0.1")!
        XCTAssertNil(url.ipSafePort)

        url = URL(string: "123.456.789.123:8080")!
        XCTAssertEqual(url.ipSafePort, 8080)
    }
}
