//
//  EnrollmentTokenInteractorTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 6/10/22.
//

import XCTest
@testable import SensoryCloud

class EnrollmentTokenInteractorTests: XCTestCase {

    var mockKeychain = MockKeychainPersistence()
    var interactor = EnrollmentTokenInteractor()

    var mockEnrollmentTokenExpires: Sensory_Api_Common_EnrollmentToken {
        var t = Sensory_Api_Common_EnrollmentToken()
        t.expiration = 300
        t.token = Data(repeating: 2, count: 10)
        return t
    }

    var mockEnrollmentToken: Sensory_Api_Common_EnrollmentToken {
        var t = Sensory_Api_Common_EnrollmentToken()
        t.expiration = 0
        t.token = Data(repeating: 3, count: 10)
        return t
    }

    override func setUpWithError() throws {
        mockKeychain.reset()
        interactor = EnrollmentTokenInteractor(persistence: mockKeychain)
    }

    func testGetSaveEnrollmentToken() throws {
        var res = try interactor.getEnrollmentToken(enrollmentID: "bogus")
        XCTAssertNil(res)

        try interactor.saveEnrollmentToken(enrollmentID: "enrollment", token: mockEnrollmentToken)
        res = try interactor.getEnrollmentToken(enrollmentID: "enrollment")
        XCTAssertEqual(res, mockEnrollmentToken.token)

        try interactor.saveEnrollmentToken(enrollmentID: "enrollment", token: mockEnrollmentTokenExpires)
        res = try interactor.getEnrollmentToken(enrollmentID: "enrollment")
        XCTAssertEqual(res, mockEnrollmentTokenExpires.token)

        let past = Date().addingTimeInterval(-300).timeIntervalSince1970
        let pastData = withUnsafeBytes(of: past) { Data($0) }
        try mockKeychain.save(id: "enrollment-expiration", data: pastData)

        XCTAssertThrowsError(try interactor.getEnrollmentToken(enrollmentID: "enrollment"))

    }

    func testDeleteEnrollmentToken() throws {
        try interactor.deleteEnrollmentToken(enrollmentID: "enrollment")

        try interactor.saveEnrollmentToken(enrollmentID: "enrollment", token: mockEnrollmentTokenExpires)
        try interactor.deleteEnrollmentToken(enrollmentID: "enrollment")

        let res = try interactor.getEnrollmentToken(enrollmentID: "enrollment")
        XCTAssertNil(res)

        mockKeychain.deleteError = KeychainError.deleteError(nil)
        XCTAssertThrowsError(try interactor.deleteEnrollmentToken(enrollmentID: "enrollment"))
    }
}
