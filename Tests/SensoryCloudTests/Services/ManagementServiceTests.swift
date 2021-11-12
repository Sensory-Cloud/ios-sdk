//
//  ManagementServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/11/21.
//

import XCTest
@testable import SensoryCloud
import GRPC

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

    func testGetEnrollments() throws {
        let mockClient = Sensory_Api_V1_Management_EnrollmentServiceTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol.self, client: mockClient)
        let managementService = ManagementService(service: mockService)

        var enrollment = Sensory_Api_V1_Management_EnrollmentResponse()
        enrollment.userID = "Some User"
        enrollment.modelName = "Mock Model"
        enrollment.deviceID = "Device ID"
        enrollment.deviceName = "Device Name"
        var expectedResponse = Sensory_Api_V1_Management_GetEnrollmentsResponse()
        expectedResponse.enrollments = [enrollment]

        var expectedRequest = Sensory_Api_V1_Management_GetEnrollmentsRequest()
        expectedRequest.userID = "Some User"

        let mockStream = mockClient.makeGetEnrollmentsResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultUnaryHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                break
            }
        }

        let rsp = managementService.getEnrollments(for: "Some User")
        try mockStream.sendMessage(expectedResponse)
        rsp.whenSuccess { [weak self] enrollments in
            XCTAssertEqual(expectedResponse, enrollments)
            self?.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testGetEnrollmentGroups() throws {
        let mockClient = Sensory_Api_V1_Management_EnrollmentServiceTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol.self, client: mockClient)
        let managementService = ManagementService(service: mockService)

        var enrollmentGroup = Sensory_Api_V1_Management_EnrollmentGroupResponse()
        enrollmentGroup.userID = "User"
        enrollmentGroup.enrollments = []
        enrollmentGroup.modelName = "Some Model"
        enrollmentGroup.description_p = "An enrollment group"
        var expectedResponse = Sensory_Api_V1_Management_GetEnrollmentGroupsResponse()
        expectedResponse.enrollmentGroups = [enrollmentGroup]

        var expectedRequest = Sensory_Api_V1_Management_GetEnrollmentsRequest()
        expectedRequest.userID = "User"

        let mockStream = mockClient.makeGetEnrollmentGroupsResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultUnaryHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                break
            }
        }

        let rsp = managementService.getEnrollmentGroups(for: "User")
        try mockStream.sendMessage(expectedResponse)
        rsp.whenSuccess { [weak self] enrollments in
            XCTAssertEqual(expectedResponse, enrollments)
            self?.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testCreateEnrollmentGroup() throws {
        let mockClient = Sensory_Api_V1_Management_EnrollmentServiceTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol.self, client: mockClient)
        let managementService = ManagementService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Management_EnrollmentGroupResponse()
        expectedResponse.userID = "Some User"
        expectedResponse.description_p = "An Enrollment group"
        expectedResponse.modelName = "Some Name"

        var expectedRequest = Sensory_Api_V1_Management_CreateEnrollmentGroupRequest()
        expectedRequest.id = "Group ID"
        expectedRequest.name = "Group Name"
        expectedRequest.description_p = "Some Enrollment Group"
        expectedRequest.modelName = "Some Model"
        expectedRequest.userID = "user"

        let mockStream = mockClient.makeCreateEnrollmentGroupResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultUnaryHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                break
            }
        }

        let rsp = managementService.createEnrollmentGroup(
            userID: "USER", // Assert USER gets converted to lowercase
            groupID: "Group ID",
            groupName: "Group Name",
            description: "Some Enrollment Group",
            modelName: "Some Model"
        )
        try mockStream.sendMessage(expectedResponse)
        rsp.whenSuccess { [weak self] enrollments in
            XCTAssertEqual(expectedResponse, enrollments)
            self?.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testAppendEnrollmentGroup() throws {
        let mockClient = Sensory_Api_V1_Management_EnrollmentServiceTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol.self, client: mockClient)
        let managementService = ManagementService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Management_EnrollmentGroupResponse()
        expectedResponse.userID = "Some User"
        expectedResponse.description_p = "An Enrollment group"
        expectedResponse.modelName = "Some Name"

        var expectedRequest = Sensory_Api_V1_Management_AppendEnrollmentGroupRequest()
        expectedRequest.groupID = "Enrollment Group"
        expectedRequest.enrollmentIds = ["First Enrollment", "Second Enrollment"]

        let mockStream = mockClient.makeAppendEnrollmentGroupResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultUnaryHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                break
            }
        }

        let rsp = managementService.appendEnrollmentGroup(
            groupId: "Enrollment Group",
            enrollments: ["First Enrollment", "Second Enrollment"]
        )
        try mockStream.sendMessage(expectedResponse)
        rsp.whenSuccess { [weak self] enrollments in
            XCTAssertEqual(expectedResponse, enrollments)
            self?.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testDeleteEnrollment() throws {
        let mockClient = Sensory_Api_V1_Management_EnrollmentServiceTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol.self, client: mockClient)
        let managementService = ManagementService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Management_EnrollmentResponse()
        expectedResponse.userID = "Some User"
        expectedResponse.modelName = "Mock Model"
        expectedResponse.deviceID = "Device ID"
        expectedResponse.deviceName = "Device Name"

        var expectedRequest = Sensory_Api_V1_Management_DeleteEnrollmentRequest()
        expectedRequest.id = "Enrollment ID"

        let mockStream = mockClient.makeDeleteEnrollmentResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultUnaryHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                break
            }
        }

        let rsp = managementService.deleteEnrollment(with: "Enrollment ID")
        try mockStream.sendMessage(expectedResponse)
        rsp.whenSuccess { [weak self] enrollments in
            XCTAssertEqual(expectedResponse, enrollments)
            self?.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testDeleteEnrollments() throws {
        let mockClient = Sensory_Api_V1_Management_EnrollmentServiceTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol.self, client: mockClient)
        let managementService = ManagementService(service: mockService)

        var expectedResponse1 = Sensory_Api_V1_Management_EnrollmentResponse()
        expectedResponse1.deviceName = "First Response"
        var expectedResponse2 = Sensory_Api_V1_Management_EnrollmentResponse()
        expectedResponse2.deviceName = "Second Response"
        var expectedResponse3 = Sensory_Api_V1_Management_EnrollmentResponse()
        expectedResponse3.deviceName = "Third Response"

        var expectedRequest1 = Sensory_Api_V1_Management_DeleteEnrollmentRequest()
        expectedRequest1.id = "First Request"
        var expectedRequest2 = Sensory_Api_V1_Management_DeleteEnrollmentRequest()
        expectedRequest2.id = "Second Request"
        var expectedRequest3 = Sensory_Api_V1_Management_DeleteEnrollmentRequest()
        expectedRequest3.id = "Third Request"
        var expectedRequests = [expectedRequest1, expectedRequest2, expectedRequest3]

        func handleMockStreamResponse(part: FakeRequestPart<Sensory_Api_V1_Management_DeleteEnrollmentRequest>) {
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self.mockService.defaultUnaryHeaders, headers)
                self.expectRequestMetadata.fulfill()
            case .message(let message):
                let expectedRequest = expectedRequests.first
                expectedRequests.remove(at: 0)
                XCTAssertEqual(expectedRequest, message)
                self.expectRequest.fulfill()
            case .end:
                break
            }
        }
        let mockStream1 = mockClient.makeDeleteEnrollmentResponseStream(handleMockStreamResponse)
        let mockStream2 = mockClient.makeDeleteEnrollmentResponseStream(handleMockStreamResponse)
        let mockStream3 = mockClient.makeDeleteEnrollmentResponseStream(handleMockStreamResponse)

        let rsp = managementService.deleteEnrollments(with: ["First Request", "Second Request", "Third Request"])

        try mockStream1.sendMessage(expectedResponse1)
        try mockStream2.sendMessage(expectedResponse2)
        try mockStream3.sendMessage(expectedResponse3)

        rsp.whenSuccess { [weak self] enrollments in
            XCTAssertEqual([expectedResponse1, expectedResponse2, expectedResponse3], enrollments)
            self?.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
        XCTAssert(expectedRequests.isEmpty, "Three grpc calls should be made")
    }

    func testDeleteEnrollmentGroup() throws {
        let mockClient = Sensory_Api_V1_Management_EnrollmentServiceTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Management_EnrollmentServiceClientProtocol.self, client: mockClient)
        let managementService = ManagementService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Management_EnrollmentGroupResponse()
        expectedResponse.userID = "Some User"
        expectedResponse.description_p = "An Enrollment group"
        expectedResponse.modelName = "Some Name"

        var expectedRequest = Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest()
        expectedRequest.id = "Group ID"

        let mockStream = mockClient.makeDeleteEnrollmentGroupResponseStream { [weak self] part in
            switch part {
            case .metadata(let headers):
                XCTAssertEqual(self?.mockService.defaultUnaryHeaders, headers)
                self?.expectRequestMetadata.fulfill()
            case .message(let message):
                XCTAssertEqual(expectedRequest, message)
                self?.expectRequest.fulfill()
            case .end:
                break
            }
        }

        let rsp = managementService.deleteEnrollmentGroup(with: "Group ID")
        try mockStream.sendMessage(expectedResponse)
        rsp.whenSuccess { [weak self] enrollments in
            XCTAssertEqual(expectedResponse, enrollments)
            self?.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }

    func testEnrollDevice() throws {
        let mockClient = Sensory_Api_V1_Management_DeviceServiceTestClient()
        mockService.setClient(forType: Sensory_Api_V1_Management_DeviceServiceClientProtocol.self, client: mockClient)
        let managementService = ManagementService(service: mockService)

        var expectedResponse = Sensory_Api_V1_Management_DeviceResponse()
        expectedResponse.deviceID = "Device ID"
        expectedResponse.name = "Device Name"

        var clientRequest = Sensory_Api_V1_Management_CreateGenericClientRequest()
        clientRequest.clientID = "client ID"
        clientRequest.secret = "client Secret"
        var expectedRequest = Sensory_Api_V1_Management_EnrollDeviceRequest()
        expectedRequest.client = clientRequest
        expectedRequest.name = "Device Name"
        expectedRequest.deviceID = "Device ID"
        expectedRequest.tenantID = "Tenant ID"
        expectedRequest.credential = "Credential"

        let mockStream = mockClient.makeEnrollDeviceResponseStream { [weak self] part in
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

        let rsp = managementService.enrollDevice(
            tenantID: "Tenant ID",
            name: "Device Name",
            deviceID: "Device ID",
            credential: "Credential",
            clientID: "client ID",
            clientSecret: "client Secret"
        )
        try mockStream.sendMessage(expectedResponse)
        rsp.whenSuccess { [weak self] enrollments in
            XCTAssertEqual(expectedResponse, enrollments)
            self?.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [expectResponse, expectRequest, expectRequestMetadata], timeout: 1)
    }
}
