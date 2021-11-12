//
//  ServiceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/10/21.
//

import XCTest
@testable import SensoryCloud
import GRPC

final class ServiceTests: XCTestCase {

    var credentialProvider = MockCredentialProvider()

    override func setUp() {
        Config.cloudHost = nil
        credentialProvider.reset()
        Service.shared.cachedClients.removeAll()
        Service.shared.cacheHost = nil
    }

    func testGetClientConnection() throws {
        let service = Service.shared

        do {
            _ = try service.getGRPCChannel()
            XCTFail("Error should occur when no cloud host set")
        } catch NetworkError.notInitialized {
            // Expected Error Case
        } catch {
            XCTFail("Wrong error thrown: \(error.localizedDescription)")
        }

        Config.setCloudHost(host: "host", port: 443)
        _ = try service.getGRPCChannel()
    }

    func testGetClient() throws {
        let service = Service.shared

        do {
            let _: Sensory_Api_V1_Audio_AudioModelsClientProtocol = try service.getClient()
            XCTFail("Error should occur when no cloud host is set")
        } catch {
            // Expected Error case
        }

        Config.setCloudHost(host: "host", port: 443)
        do {
            let _: Sensory_Api_V1_Audio_AudioModelsClient = try service.getClient()
            XCTFail("Error should occur when client type is passed, instead of protocol")
        } catch {
            // Expected Error case
        }


        let _: Sensory_Api_V1_Audio_AudioModelsClientProtocol = try service.getClient()
        XCTAssertEqual(service.cachedClients.count, 1)
        XCTAssertEqual(service.cacheHost, CloudHost(host: "host", port: 443, isSecure: true))

        // Ensure cache is being used
        let _: Sensory_Api_V1_Audio_AudioModelsClientProtocol = try service.getClient()
        XCTAssertEqual(service.cachedClients.count, 1)

        let _: Sensory_Api_V1_Video_VideoModelsClientProtocol = try service.getClient()
        XCTAssertEqual(service.cachedClients.count, 2)

        // Ensure cache gets reset when the cloud host changes
        Config.setCloudHost(host: "NewHost", port: 444)
        let _: Sensory_Api_V1_Audio_AudioModelsClientProtocol = try service.getClient()
        XCTAssertEqual(service.cachedClients.count, 1)
    }

    func testGetDefaultMetadata() throws {
        Service.shared.credentialProvider = credentialProvider
        let service = Service.shared

        do {
            _ = try service.getDefaultMetadata()
            XCTFail("Error should be propagated from credential provider")
        } catch {
            // Expected Error case
        }

        credentialProvider.accessToken = "mockToken"
        var metadata = try service.getDefaultMetadata()
        XCTAssertEqual(metadata.customMetadata.count, 1)
        var oauthHeader = metadata.customMetadata.first!
        XCTAssertEqual(oauthHeader.name, "authorization")
        XCTAssertEqual(oauthHeader.value, "Bearer mockToken")
        XCTAssertEqual(metadata.timeLimit, TimeLimit.none)

        metadata = try service.getDefaultMetadata(isUnary: true)
        XCTAssertEqual(metadata.customMetadata.count, 1)
        oauthHeader = metadata.customMetadata.first!
        XCTAssertEqual(oauthHeader.name, "authorization")
        XCTAssertEqual(oauthHeader.value, "Bearer mockToken")
        XCTAssertEqual(metadata.timeLimit, TimeLimit.timeout(.seconds(10)))
    }
}
