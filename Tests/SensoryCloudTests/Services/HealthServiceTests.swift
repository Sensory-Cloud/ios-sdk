//
//  HealthServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 3/13/22.
//

import XCTest
@testable import SensoryCloud
import GRPC
import NIOCore
import NIOPosix

final class HealthServiceTests: XCTestCase {
    static var group: EventLoopGroup!
    static var server: Server!

    static var expectResponse = XCTestExpectation(description: "grpc response should be received")
    static var expectRequest = XCTestExpectation(description: "grpc request should be sent")

    static var expectedRequest = Sensory_Api_Health_HealthRequest()
    static var expectedResponse: Sensory_Api_Common_ServerHealthResponse {
        var rsp = Sensory_Api_Common_ServerHealthResponse()
        rsp.id = "identifier"
        rsp.isHealthy = true
        rsp.serverVersion = "0.1.0"
        return rsp
    }

    override class func setUp() {
        super.setUp()

        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        server = try! Server.insecure(group: group)
            .withServiceProviders([HealthServiceProvider()])
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
        HealthServiceTests.expectResponse = XCTestExpectation(description: "grpc response should be received")
        HealthServiceTests.expectRequest = XCTestExpectation(description: "grpc request should be sent")
    }

    func testGetHealth() throws {
        let healthService = HealthService()

        let rsp = healthService.getHealth()
        rsp.whenSuccess { response in
            XCTAssertEqual(HealthServiceTests.expectedResponse, response)
            HealthServiceTests.expectResponse.fulfill()
        }
        rsp.whenFailure { error in
            XCTFail("Call should be successful: \(error.localizedDescription)")
        }

        wait(for: [HealthServiceTests.expectResponse, HealthServiceTests.expectRequest], timeout: 1)
    }
}

final class HealthServiceProvider: Sensory_Api_Health_HealthServiceProvider {
    var interceptors: SensoryCloud.Sensory_Api_Health_HealthServiceServerInterceptorFactoryProtocol? = nil

    func getHealth(
        request: SensoryCloud.Sensory_Api_Health_HealthRequest,
        context: GRPC.StatusOnlyCallContext) -> NIOCore.EventLoopFuture<SensoryCloud.Sensory_Api_Common_ServerHealthResponse>
    {
        assertRequestMetadata(context: context)
        XCTAssertEqual(HealthServiceTests.expectedRequest, request)
        HealthServiceTests.expectRequest.fulfill()
        return context.eventLoop.makeSucceededFuture(HealthServiceTests.expectedResponse)
    }
}

func assertRequestMetadata(context: GRPC.StatusOnlyCallContext, accessToken: String? = nil) {
    if let token = accessToken {
        XCTAssertEqual(context.headers["authorization"].count, 1)
        XCTAssertEqual(context.headers["authorization"].first, "Bearer \(token)")
    } else {
        XCTAssert(context.headers["authorization"].isEmpty, "Standard auth headers should not be sent")
    }
}

func assertRequestMetadata<T>(context: GRPC.StreamingResponseCallContext<T>, accessToken: String? = nil) {
    if let token = accessToken {
        XCTAssertEqual(context.headers["authorization"].count, 1)
        XCTAssertEqual(context.headers["authorization"].first, "Bearer \(token)")
    } else {
        XCTAssert(context.headers["authorization"].isEmpty, "Standard auth headers should not be sent")
    }
}
