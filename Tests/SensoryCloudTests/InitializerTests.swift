//
//  InitializerTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/11/22.
//

import XCTest
@testable import SensoryCloud

// Test resources lose their directory structure when copied to the test bundle :(
private let filePrefix = "Initializer_"

class InitializerTests: XCTestCase {

    var mockDeviceResponse: Sensory_Api_V1_Management_DeviceResponse {
        var rsp = Sensory_Api_V1_Management_DeviceResponse()
        rsp.name = "MockDeviceName"
        rsp.deviceID = "MockDeviceID"
        return rsp
    }

    var expectCallback = XCTestExpectation(description: "Initialize callback should be called")

    var tokenManager = MockTokenManager()
    var oauthService = MockOAuthService()

    override func setUp() {
        tokenManager.reset()
        oauthService.reset()
        Initializer.tokenManager = tokenManager
        Initializer.oauthService = oauthService

        Config.tenantID = nil
        Config.deviceID = nil
        Config.setCloudHost(host: "")

        expectCallback = XCTestExpectation(description: "Initialize callback should be called")
    }

    // MARK: - init from static config
    func testInitialize() throws {
        tokenManager.credentials = AccessTokenCredentials(clientID: "client", secret: "secret")
        oauthService.enrollResponse = mockDeviceResponse

        let initConfig = SDKInitConfig("sensorycloud.ai", true, "tenant", .sharedSecret, "password", "devID", "my device")
        Initializer.initialize(config: initConfig) { [weak self] result in
            self?.assertResult(result: result, initConfig: initConfig)
            self?.expectCallback.fulfill()
        }
        wait(for: [expectCallback], timeout: 1)
    }

    func testInitializeSavedCredentials() throws {
        tokenManager.mockHasCredentials = true

        let initConfig = SDKInitConfig("127.0.0.1:8080", true, "tenantID", .none, "doesn't matter", "devID", "name")

        Initializer.initialize(config: initConfig) { [weak self] result in
            switch result {
            case .success(let rsp):
                XCTAssertNil(rsp)
                XCTAssertNil(self?.oauthService.name)
                XCTAssertEqual(Config.tenantID, initConfig.tenantID)
                if initConfig.deviceID == nil {
                    XCTAssertFalse(Config.deviceID?.isEmpty ?? true)
                } else {
                    XCTAssertEqual(Config.deviceID, initConfig.deviceID)
                }
                let host = parseURL(initConfig.fullyQualifiedDomainName)
                XCTAssertEqual(Config.getCloudHost(), host)
                break
            case .failure:
                XCTFail("Call should not fail")
            }
            self?.expectCallback.fulfill()
        }
        wait(for: [expectCallback], timeout: 1)
    }

    // MARK: - Init from file
    func testInitializeJSON() throws {
        tokenManager.credentials = AccessTokenCredentials(clientID: "client", secret: "secret")
        oauthService.enrollResponse = mockDeviceResponse

        let expectedConfig = SDKInitConfig("127.0.0.1:8080", true, "tenant", .jwt, "doesnt-matter", "device_id", "device_name")
        let url = loadFile(named: "config", ext: "json")
        Initializer.initialize(configFile: url) { [weak self] result in
            self?.assertResult(result: result, initConfig: expectedConfig)
            self?.expectCallback.fulfill()
        }
        wait(for: [expectCallback], timeout: 1)
    }

    func testInitializePlist() throws {
        tokenManager.credentials = AccessTokenCredentials(clientID: "client", secret: "secret")
        oauthService.enrollResponse = mockDeviceResponse

        let expectedConfig = SDKInitConfig("sensorycloud.ai", true, "tenant", .sharedSecret, "password", "device_id", "device_name")
        let url = loadFile(named: "config", ext: "plist")
        Initializer.initialize(configFile: url) { [weak self] result in
            self?.assertResult(result: result, initConfig: expectedConfig)
            self?.expectCallback.fulfill()
        }
        wait(for: [expectCallback], timeout: 1)
    }

    func testInitializeEnv() throws {
        tokenManager.credentials = AccessTokenCredentials(clientID: "client", secret: "secret")
        oauthService.enrollResponse = mockDeviceResponse

        let expectedConfig = SDKInitConfig("sensorycloud.ai", true, "tenant", .sharedSecret, "password", "device_id", "device_name")
        let url = loadFile(named: "config", ext: "env")
        Initializer.initialize(configFile: url) { [weak self] result in
            self?.assertResult(result: result, initConfig: expectedConfig)
            self?.expectCallback.fulfill()
        }
        wait(for: [expectCallback], timeout: 1)
    }

    func testInitializeINI() throws {
        tokenManager.credentials = AccessTokenCredentials(clientID: "client", secret: "secret")
        oauthService.enrollResponse = mockDeviceResponse

        let expectedConfig = SDKInitConfig("127.0.0.1:8080", true, "tenant", .jwt, "doesnt-matter", "device_id", "device_name")
        let url = loadFile(named: "config", ext: "ini")
        Initializer.initialize(configFile: url) { [weak self] result in
            self?.assertResult(result: result, initConfig: expectedConfig)
            self?.expectCallback.fulfill()
        }
        wait(for: [expectCallback], timeout: 1)
    }

    // MARK: - Error cases
    func testInitializeParseError() throws {
        let initConfig = SDKInitConfig("bogus fqdn", false, "...", .none, "...")
        Initializer.initialize(config: initConfig) { [weak self] result in
            switch result {
            case .success:
                XCTFail("Call should fail")
            case .failure:
                self?.assertNoConfig()
                XCTAssertNil(self?.oauthService.name)
            }
            self?.expectCallback.fulfill()
        }
        wait(for: [expectCallback], timeout: 1)
    }

    func testInitializeOauthError() throws {
        let initConfig = SDKInitConfig("sensorycloud.ai", false, "...", .none, "...")
        tokenManager.generateError = KeychainError.expired
        Initializer.initialize(config: initConfig) { [weak self] result in
            switch result {
            case .success:
                XCTFail("Call should fail")
            case .failure:
                self?.assertNoConfig()
                XCTAssertNil(self?.oauthService.name)
            }
            self?.expectCallback.fulfill()
        }
        wait(for: [expectCallback], timeout: 1)
    }

    func testInitializeJWTError() throws {
        let initConfig = SDKInitConfig("sensorycloud.ai", false, "...", .jwt, "bogus private key")
        tokenManager.credentials = AccessTokenCredentials(clientID: "...", secret: "...")
        Initializer.initialize(config: initConfig) { [weak self] result in
            switch result {
            case .success:
                XCTFail("Call should fail")
            case .failure:
                self?.assertNoConfig()
                XCTAssertNil(self?.oauthService.name)
            }
            self?.expectCallback.fulfill()
        }
        wait(for: [expectCallback], timeout: 1)
    }

    func testInitializeGRPCError() throws {
        let initConfig = SDKInitConfig("sensorycloud.ai", false, "...", .none, "...")
        tokenManager.credentials = AccessTokenCredentials(clientID: "...", secret: "...")
        oauthService.networkError = KeychainError.expired
        Initializer.initialize(config: initConfig) { [weak self] result in
            switch result {
            case .success:
                XCTFail("Call should fail")
            case .failure:
                self?.assertNoConfig()
                XCTAssert(self?.oauthService.name != nil)
            }
            self?.expectCallback.fulfill()
        }
        wait(for: [expectCallback], timeout: 1)
    }

    // MARK: - helper methods
    func assertResult(result: SDKinitResult, initConfig: SDKInitConfig) {
        switch result {
        case .success(let rsp):
            XCTAssertEqual(Config.tenantID, initConfig.tenantID)
            if initConfig.deviceID == nil {
                XCTAssertFalse(Config.deviceID?.isEmpty ?? true)
            } else {
                XCTAssertEqual(Config.deviceID, initConfig.deviceID)
            }
            let host = parseURL(initConfig.fullyQualifiedDomainName, initConfig.isSecure)
            XCTAssertEqual(Config.getCloudHost(), host)

            XCTAssertEqual(oauthService.name, initConfig.deviceName)
            XCTAssertEqual(oauthService.clientID, tokenManager.credentials?.clientID)
            XCTAssertEqual(oauthService.secret, tokenManager.credentials?.secret)
            switch initConfig.enrollmentType {
            case .sharedSecret:
                XCTAssertEqual(oauthService.credential, initConfig.credential)
            case .jwt:
                XCTAssertFalse(oauthService.credential?.isEmpty ?? true)
            case .none:
                XCTAssertTrue(oauthService.credential?.isEmpty ?? false)
            }

            XCTAssertEqual(rsp, mockDeviceResponse)
        case .failure:
            XCTFail("Call should not fail")
        }
    }

    func assertNoConfig() {
        XCTAssertNil(Config.deviceID)
        XCTAssertNil(Config.tenantID)
        XCTAssertEqual(Config.getCloudHost()?.host, "")
    }

    func loadFile(named: String, ext: String? = nil) -> URL? {
        return Bundle.module.url(forResource: filePrefix + named, withExtension: ext)
    }
}
