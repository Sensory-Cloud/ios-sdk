//
//  HealthServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 3/13/22.
//

import XCTest
@testable import SensoryCloud
import GRPC

final class HealthServiceTests: XCTestCase {

    var mockService = MockService()
    var expectResponse = XCTestExpectation(description: "grpc response should be received")
    var expectRequestMetadata = XCTestExpectation(description: "request metadata should be sent")
    var expectRequest = XCTestExpectation(description: "grpc request should be sent")

    override func setUp() {
        resetExpectation()
        mockService.reset()
        Config.deviceID = nil
        Config.tenantID = nil
    }

    func resetExpectation() {
        expectResponse = XCTestExpectation(description: "grpc response should be received")
        expectRequestMetadata = XCTestExpectation(description: "request metadata should be sent")
        expectRequest = XCTestExpectation(description: "grpc request should be sent")
    }

    func testGetHealth() throws {
        let mockClient = Sensory_Api_Health_HealthServiceTestClient()
        mockService.setClient(forType: Sensory_Api_Health_HealthServiceClientProtocol.self, client: mockClient)
        let healthService = HealthService(service: mockService)

        var expectedResponse = Sensory_Api_Common_ServerHealthResponse()
        expectedResponse.id = "identifier"
        expectedResponse.isHealthy = true
        expectedResponse.serverVersion = "0.1.0"

        let expectedRequest = Sensory_Api_Health_HealthRequest()

        let mockStream = mockClient.makeGetHealthResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssert(headers.isEmpty, "Standard auth header should not be sent")
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                break
            }
        }

        let rsp = healthService.getHealth()
        try mockStream.sendMessage(expectedResponse)
        rsp.whenSuccess { [weak self] response in
            XCTAssertEqual(expectedResponse, response)
            self?.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }
}
