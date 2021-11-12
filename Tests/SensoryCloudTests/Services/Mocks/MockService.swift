//
//  MockService.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/11/21.
//

import Foundation
@testable import SensoryCloud
import GRPC
import NIOHPACK

class MockService: Service {

    var mockClients: [String: Any] = [:]
    var metadataError: Error?

    let defaultUnaryHeaders: HPACKHeaders = ["mockServiceHeader": "true", "isUnary": "true"]
    let defaultStreamHeaders: HPACKHeaders = ["mockServiceHeader": "true", "isUnary": "false"]

    override init() {
        super.init()
        credentialProvider = MockCredentialProvider()
    }

    deinit {
        do {
            try group.syncShutdownGracefully()
        } catch {
            NSLog("could not gracefully shutdown group: \(error.localizedDescription)")
        }
    }

    func setClient<T>(forType: T.Type, client: Any) {
        mockClients["\(T.self)"] = client
    }

    override func getClient<T>() throws -> T {
        guard let mockClient = mockClients["\(T.self)"] as? T else {
            throw NetworkError.invalidClientClass("\(T.self)")
        }
        return mockClient
    }

    override func getDefaultMetadata(isUnary: Bool = false) throws -> CallOptions {
        if let error = metadataError {
            throw error
        }

        if isUnary {
            return CallOptions(customMetadata: defaultUnaryHeaders)
        } else {
            return CallOptions(customMetadata: defaultStreamHeaders)
        }
    }

    func reset() {
        mockClients.removeAll()
        metadataError = nil
    }
}
