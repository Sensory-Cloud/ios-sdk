//
//  JWTManager.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/10/22.
//

import Foundation
import CryptoKit

extension Data {
    func urlSafeBase64EncodedString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

struct Header: Encodable {
    let alg = "EdDSA"
    let typ = "JWT"
}

struct Payload: Encodable {
    let name, tenant, client: String
}

func genJWT(enrollmentKey: String, deviceName: String, tenantID: String, clientID: String) throws -> String {

    let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: enrollmentKey.hexData)

    let headerJSONData = try JSONEncoder().encode(Header())
    let headerBase64String = headerJSONData.urlSafeBase64EncodedString()

    let payload = Payload(name: deviceName, tenant: tenantID, client: clientID)
    let payloadJSONData = try JSONEncoder().encode(payload)
    let payloadBase64String = payloadJSONData.urlSafeBase64EncodedString()

    guard let toSign = (headerBase64String + "." + payloadBase64String).data(using: .utf8) else {
        throw SensoryCloud.KeychainError.encodingError
    }

    let signature = try privateKey.signature(for: toSign)
    let signatureBase64String = Data(signature).urlSafeBase64EncodedString()

    let token = [headerBase64String, payloadBase64String, signatureBase64String].joined(separator: ".")
    return token
}
