//
//  KeychainPersistenceTests.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/8/21.
//

import XCTest
@testable import SensoryCloud

final class KeychainPersistenceTests: XCTestCase {

    let keychain = KeychainPersistence()
    let id1 = "UnitTestID1"
    let id2 = "UnitTestID2"
    let id3 = "UnitTestID3"

    static var shouldSkip = false

    override class func setUp() {
        // Check to see if we have keychain entitlements
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: "test"
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status == errSecMissingEntitlement {
            shouldSkip = true
        }
    }

    override func setUpWithError() throws {
        try XCTSkipIf(Self.shouldSkip, "Skipping keychain tests, missing keychain entitlements")

        try keychain.delete(id: id1)
        try keychain.delete(id: id2)
        try keychain.delete(id: id3)
    }

    func testSaveString() throws {
        try keychain.save(id: id1, string: "Some String")
        try keychain.save(id: id1, string: "Some Overriding String")
        try keychain.save(id: id2, string: "Some Other String")
    }

    func testSaveData() throws {
        try keychain.save(id: id1, data: Data(repeating: 2, count: 3))
        try keychain.save(id: id1, data: Data(repeating: 5, count: 10))
    }

    func testGetString() throws {
        do {
            _ = try keychain.getString(id: id3)
            XCTFail("An error should be thrown when the item cannot be found")
        } catch KeychainError.itemNotFound(_) {
            // Expected Error case
        } catch {
            XCTFail("ItemNotFound should be thrown")
        }

        try keychain.save(id: id3, string: "Some String")
        let result = try keychain.getString(id: id3)
        XCTAssertEqual(result, "Some String")

        try keychain.save(id: id2, data: Data(repeating: 10, count: 50))
        do {
            _ = try keychain.getString(id: id2)
            XCTFail("An error should be thrown if the data cannot be converted to a string")
        } catch {
            // Expected Error case
        }
    }

    func testGetData() throws {
        do {
            _ = try keychain.getData(id: id3)
            XCTFail("An error should be thrown when the item cannot be found")
        } catch KeychainError.itemNotFound(_) {
            // Expected Error case
        } catch {
            XCTFail("ItemNotFound should be thrown")
        }

        try keychain.save(id: id3, data: Data(repeating: 5, count: 20))
        let result = try keychain.getData(id: id3)
        XCTAssertEqual(result, Data(repeating: 5, count: 20))

        try keychain.save(id: id2, string: "Some Testing String")
        // keychain get should pass since the string can be converted into data
        _ = try keychain.getData(id: id2)
    }

    func testDelete() throws {
        // Delete w/ item not found should pass
        try keychain.delete(id: id1)

        try keychain.save(id: id1, string: "String")
        try keychain.save(id: id2, data: Data(repeating: 4, count: 20))
        try keychain.delete(id: id1)
        try keychain.delete(id: id2)

        do {
            _ = try keychain.getString(id: id1)
            XCTFail("Item should be deleted")
        } catch {
            // Expected Error case
        }

        do {
            _ = try keychain.getData(id: id2)
            XCTFail("Item should be deleted")
        } catch {
            // Expected Error case
        }
    }
}
