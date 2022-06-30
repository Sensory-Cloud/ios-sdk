//
//  JWTManagerTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/11/22.
//

import XCTest
@testable import SensoryCloud

class JWTManagerTests: XCTestCase {

    func testGenJWT() throws {

        let expectedJWT = """
eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.\
eyJuYW1lIjoiTXkgZGV2aWNlIiwidGVuYW50IjoiTXkgdGVuYW50IiwiY2xpZW50IjoiTXkgY2xpZW50In0.
"""

        let jwt = try genJWT(
            enrollmentKey: "de6101434b38c83dcc5d3795d42aad828d4f4ac515908c10989780c450287c8c",
            deviceName: "My device",
            tenantID: "My tenant",
            clientID: "My client"
        )
        XCTAssertTrue(jwt.hasPrefix(expectedJWT))
        
        XCTAssertThrowsError(try genJWT(
            enrollmentKey: "bogus",
            deviceName: "dev",
            tenantID: "ten",
            clientID: "cli"
        ))
    }

}
