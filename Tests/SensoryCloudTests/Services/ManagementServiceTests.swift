//
//  ManagementServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/11/21.
//

import XCTest
@testable import SensoryCloud

final class ManagementServiceTests: XCTestCase {

    var mockService = MockService()
    var expectResponse = XCTestExpectation(description: "grpc response should be received")
    var expectRequestMetadata = XCTestExpectation(description: "request metadata should be sent")
    var expectRequest = XCTestExpectation(description: "grpc request should be sent")

    override func setUp() {
        resetExpectation()
        mockService.reset()
    }

    func resetExpectation() {
        expectResponse = XCTestExpectation(description: "grpc response should be received")
        expectRequestMetadata = XCTestExpectation(description: "request metadata should be sent")
        expectRequest = XCTestExpectation(description: "grpc request should be sent")
    }

    func testGetEnrollments() {
        XCTFail("TODO")
    }

    func testGetEnrollmentGroups() {
        XCTFail("TODO")
    }

    func testCreateEnrollmentGroup() {
        XCTFail("TODO")
    }

    func testAppendEnrollmentGroup() {
        XCTFail("TODO")
    }

    func testDeleteEnrollment() {
        XCTFail("TODO")
    }

    func testDeleteEnrollments() {
        XCTFail("TODO")
    }

    func testDeleteEnrollmentGroup() {
        XCTFail("TODO")
    }

    func testEnrollDevice() {
        XCTFail("TODO")
    }
}
