//
//  ManagementServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/11/21.
//

import XCTest
@testable import SensoryCloud
import GRPC
import NIOCore
import NIOPosix

final class ManagementServiceTests: XCTestCase {
    static var group: EventLoopGroup!
    static var server: Server!
    static var mockCredentialProvider: MockCredentialProvider!
    static var mockToken = "Mock Access Token"

    static var expectResponse = XCTestExpectation(description: "grpc response should be received")
    static var expectRequest = XCTestExpectation(description: "grpc request should be sent")

    // Get Enrollments
    static var expectedGetEnrollmentsResponse: Sensory_Api_V1_Management_GetEnrollmentsResponse {
        var enroll = Sensory_Api_V1_Management_EnrollmentResponse()
        enroll.userID = "Some User"
        enroll.modelName = "Mock Model"
        enroll.deviceID = "Device ID"
        enroll.deviceName = "Device Name"
        var rsp = Sensory_Api_V1_Management_GetEnrollmentsResponse()
        rsp.enrollments = [enroll]
        return rsp
    }
    static var expectedGetEnrollmentsRequest: Sensory_Api_V1_Management_GetEnrollmentsRequest {
        var req = Sensory_Api_V1_Management_GetEnrollmentsRequest()
        req.userID = "Some User"
        return req
    }

    // Get Enrollment Groups
    static var expectedGetEnrollmentGroupsResponse: Sensory_Api_V1_Management_GetEnrollmentGroupsResponse {
        var group = Sensory_Api_V1_Management_EnrollmentGroupResponse()
        group.userID = "User"
        group.enrollments = []
        group.modelName = "Some Model"
        group.description_p = "An enrollment group"
        var rsp = Sensory_Api_V1_Management_GetEnrollmentGroupsResponse()
        rsp.enrollmentGroups = [group]
        return rsp
    }
    static var expectedGetEnrollmentGroupsRequest: Sensory_Api_V1_Management_GetEnrollmentsRequest {
        var req = Sensory_Api_V1_Management_GetEnrollmentsRequest()
        req.userID = "User"
        return req
    }

    // Create Enrollment Group
    static var expectedCreateEnrollmentGroupResponse: Sensory_Api_V1_Management_EnrollmentGroupResponse {
        var rsp = Sensory_Api_V1_Management_EnrollmentGroupResponse()
        rsp.userID = "Some User"
        rsp.description_p = "An Enrollment group"
        rsp.modelName = "Some Name"
        return rsp
    }
    static var expectedCreateEnrollmentGroupRequest: Sensory_Api_V1_Management_CreateEnrollmentGroupRequest {
        var req = Sensory_Api_V1_Management_CreateEnrollmentGroupRequest()
        req.id = "Group ID"
        req.name = "Group Name"
        req.description_p = "Some Enrollment Group"
        req.modelName = "Some Model"
        req.userID = "user"
        return req
    }

    // Append Enrollment Group
    static var expectedAppendEnrollmentGroupResponse: Sensory_Api_V1_Management_EnrollmentGroupResponse {
        var rsp = Sensory_Api_V1_Management_EnrollmentGroupResponse()
        rsp.userID = "Some User"
        rsp.description_p = "An Enrollment group"
        rsp.modelName = "Some Name"
        return rsp
    }
    static var expectedAppendEnrollmentGroupRequest: Sensory_Api_V1_Management_AppendEnrollmentGroupRequest {
        var req = Sensory_Api_V1_Management_AppendEnrollmentGroupRequest()
        req.groupID = "Enrollment Group"
        req.enrollmentIds = ["First Enrollment", "Second Enrollment"]
        return req
    }

    // Delete Enrollment
    static var expectedDeleteEnrollmentResponse: Sensory_Api_V1_Management_EnrollmentResponse {
        var rsp = Sensory_Api_V1_Management_EnrollmentResponse()
        rsp.userID = "Some User"
        rsp.modelName = "Mock Model"
        rsp.deviceID = "Device ID"
        rsp.deviceName = "Device Name"
        return rsp
    }
    static var expectedDeleteEnrollmentRequest: Sensory_Api_V1_Management_DeleteEnrollmentRequest {
        var req = Sensory_Api_V1_Management_DeleteEnrollmentRequest()
        req.id = "Enrollment ID"
        return req
    }

    // Delete Enrollment Group
    static var expectedDeleteEnrollmentGroupResponse: Sensory_Api_V1_Management_EnrollmentGroupResponse {
        var rsp = Sensory_Api_V1_Management_EnrollmentGroupResponse()
        rsp.userID = "Some User"
        rsp.description_p = "An Enrollment group"
        rsp.modelName = "Some Name"
        return rsp
    }
    static var expectedDeleteEnrollmentGroupRequest: Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest {
        var req = Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest()
        req.id = "Group ID"
        return req
    }

    override class func setUp() {
        super.setUp()

        mockCredentialProvider = MockCredentialProvider()
        mockCredentialProvider.accessToken = mockToken
        Service.shared.credentialProvider = mockCredentialProvider

        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        server = try! Server.insecure(group: group)
            .withServiceProviders([EnrollmentServiceProvider()])
            .bind(host: "localhost", port: 0)
            .wait()
        Config.setCloudHost(host: "localhost", port: server.channel.localAddress!.port!, isSecure: false)
    }

    override class func tearDown() {
        XCTAssertNoThrow(try self.server.initiateGracefulShutdown().wait())
        XCTAssertNoThrow(try self.group.syncShutdownGracefully())
        super.tearDown()
    }

    override func setUp() {
        super.setUp()
        resetExpectation()
    }

    func resetExpectation() {
        ManagementServiceTests.expectResponse = XCTestExpectation(description: "grpc response should be received")
        ManagementServiceTests.expectRequest = XCTestExpectation(description: "grpc request should be sent")
    }

    func testGetEnrollments() throws {
        let managementService = ManagementService()

        let rsp = managementService.getEnrollments(for: "Some User")
        rsp.whenSuccess { enrollments in
            XCTAssertEqual(ManagementServiceTests.expectedGetEnrollmentsResponse, enrollments)
            ManagementServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [ManagementServiceTests.expectResponse, ManagementServiceTests.expectRequest], timeout: 1)
    }

    func testGetEnrollmentGroups() throws {
        let managementService = ManagementService()

        let rsp = managementService.getEnrollmentGroups(for: "User")
        rsp.whenSuccess { enrollments in
            XCTAssertEqual(ManagementServiceTests.expectedGetEnrollmentGroupsResponse, enrollments)
            ManagementServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [ManagementServiceTests.expectResponse, ManagementServiceTests.expectRequest], timeout: 1)
    }

    func testCreateEnrollmentGroup() throws {
        let managementService = ManagementService()

        let rsp = managementService.createEnrollmentGroup(
            userID: "USER", // Assert USER gets converted to lowercase
            groupID: "Group ID",
            groupName: "Group Name",
            description: "Some Enrollment Group",
            modelName: "Some Model"
        )
        rsp.whenSuccess { enrollments in
            XCTAssertEqual(ManagementServiceTests.expectedCreateEnrollmentGroupResponse, enrollments)
            ManagementServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [ManagementServiceTests.expectResponse, ManagementServiceTests.expectRequest], timeout: 1)
    }

    func testAppendEnrollmentGroup() throws {
        let managementService = ManagementService()

        let rsp = managementService.appendEnrollmentGroup(
            groupId: "Enrollment Group",
            enrollments: ["First Enrollment", "Second Enrollment"]
        )
        rsp.whenSuccess { enrollments in
            XCTAssertEqual(ManagementServiceTests.expectedAppendEnrollmentGroupResponse, enrollments)
            ManagementServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [ManagementServiceTests.expectResponse, ManagementServiceTests.expectRequest], timeout: 1)
    }

    func testDeleteEnrollment() throws {
        let managementService = ManagementService()

        let rsp = managementService.deleteEnrollment(with: "Enrollment ID")
        rsp.whenSuccess { enrollments in
            XCTAssertEqual(ManagementServiceTests.expectedDeleteEnrollmentResponse, enrollments)
            ManagementServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [ManagementServiceTests.expectResponse, ManagementServiceTests.expectRequest], timeout: 1)
    }

    func testDeleteEnrollments() throws {
        let managementService = ManagementService()

        let rsp = managementService.deleteEnrollments(with: ["Enrollment ID", "Enrollment ID", "Enrollment ID"])
        rsp.whenSuccess { enrollments in
            let rsp = ManagementServiceTests.expectedDeleteEnrollmentResponse
            XCTAssertEqual([rsp, rsp, rsp], enrollments)
            ManagementServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [ManagementServiceTests.expectResponse, ManagementServiceTests.expectRequest], timeout: 1)
    }

    func testDeleteEnrollmentGroup() throws {
        let managementService = ManagementService()

        let rsp = managementService.deleteEnrollmentGroup(with: "Group ID")
        rsp.whenSuccess { enrollments in
            XCTAssertEqual(ManagementServiceTests.expectedDeleteEnrollmentGroupResponse, enrollments)
            ManagementServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [ManagementServiceTests.expectResponse, ManagementServiceTests.expectRequest], timeout: 1)
    }
}

final class EnrollmentServiceProvider: Sensory_Api_V1_Management_EnrollmentServiceProvider {
    var interceptors: SensoryCloud.Sensory_Api_V1_Management_EnrollmentServiceServerInterceptorFactoryProtocol? = nil

    func getEnrollments(
        request: SensoryCloud.Sensory_Api_V1_Management_GetEnrollmentsRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_GetEnrollmentsResponse>
    {
        assertRequestMetadata(context: context, accessToken: ManagementServiceTests.mockToken)
        XCTAssertEqual(ManagementServiceTests.expectedGetEnrollmentsRequest, request)
        ManagementServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(ManagementServiceTests.expectedGetEnrollmentsResponse)
    }

    func getEnrollmentGroups(
        request: SensoryCloud.Sensory_Api_V1_Management_GetEnrollmentsRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_GetEnrollmentGroupsResponse>
    {
        assertRequestMetadata(context: context, accessToken: ManagementServiceTests.mockToken)
        XCTAssertEqual(ManagementServiceTests.expectedGetEnrollmentGroupsRequest, request)
        ManagementServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(ManagementServiceTests.expectedGetEnrollmentGroupsResponse)
    }

    func createEnrollmentGroup(
        request: SensoryCloud.Sensory_Api_V1_Management_CreateEnrollmentGroupRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_EnrollmentGroupResponse>
    {
        assertRequestMetadata(context: context, accessToken: ManagementServiceTests.mockToken)
        XCTAssertEqual(ManagementServiceTests.expectedCreateEnrollmentGroupRequest, request)
        ManagementServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(ManagementServiceTests.expectedCreateEnrollmentGroupResponse)
    }

    func appendEnrollmentGroup(
        request: SensoryCloud.Sensory_Api_V1_Management_AppendEnrollmentGroupRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_EnrollmentGroupResponse>
    {
        assertRequestMetadata(context: context, accessToken: ManagementServiceTests.mockToken)
        XCTAssertEqual(ManagementServiceTests.expectedAppendEnrollmentGroupRequest, request)
        ManagementServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(ManagementServiceTests.expectedAppendEnrollmentGroupResponse)
    }

    func deleteEnrollment(
        request: SensoryCloud.Sensory_Api_V1_Management_DeleteEnrollmentRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_EnrollmentResponse>
    {
        assertRequestMetadata(context: context, accessToken: ManagementServiceTests.mockToken)
        XCTAssertEqual(ManagementServiceTests.expectedDeleteEnrollmentRequest, request)
        ManagementServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(ManagementServiceTests.expectedDeleteEnrollmentResponse)
    }

    func deleteEnrollmentGroup(
        request: SensoryCloud.Sensory_Api_V1_Management_DeleteEnrollmentGroupRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_EnrollmentGroupResponse>
    {
        assertRequestMetadata(context: context, accessToken: ManagementServiceTests.mockToken)
        XCTAssertEqual(ManagementServiceTests.expectedDeleteEnrollmentGroupRequest, request)
        ManagementServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(ManagementServiceTests.expectedDeleteEnrollmentGroupResponse)
    }

    // Unused
    func updateEnrollment(request: SensoryCloud.Sensory_Api_V1_Management_UpdateEnrollmentRequest, context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_EnrollmentResponse> {
        return context.eventLoop.makeFailedFuture(NetworkError.notInitialized)
    }

    func updateEnrollmentGroup(request: SensoryCloud.Sensory_Api_V1_Management_UpdateEnrollmentGroupRequest, context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_EnrollmentGroupResponse> {
        return context.eventLoop.makeFailedFuture(NetworkError.notInitialized)
    }

    func removeEnrollmentsFromGroup(request: SensoryCloud.Sensory_Api_V1_Management_RemoveEnrollmentsRequest, context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_V1_Management_EnrollmentGroupResponse> {
        return context.eventLoop.makeFailedFuture(NetworkError.notInitialized)
    }
}
