//
//  MockKeychainPersistence.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/8/21.
//

import Foundation
@testable import SensoryCloud

class MockKeychainPersistence: KeychainPersistence {

    var strings: [String: String] = [:]
    var datas: [String: Data] = [:]

    var saveError: Error?
    var getError: Error?
    var deleteError: Error?

    override func save(id: String, string: String) throws {
        if let error = saveError { throw error }
        strings[id] = string
    }

    override func save(id: String, data: Data) throws {
        if let error = saveError { throw error }
        datas[id] = data
    }

    override func getString(id: String) throws -> String {
        if let error = getError { throw error }
        if let res = strings[id] {
            return res
        }
        throw KeychainError.itemNotFound(id)
    }

    override func getData(id: String) throws -> Data {
        if let error = getError { throw error }
        if let res = datas[id] {
            return res
        }
        throw KeychainError.itemNotFound(id)
    }

    override func delete(id: String) throws {
        if let error = deleteError { throw error }
        _ = strings.removeValue(forKey: id)
        _ = datas.removeValue(forKey: id)
    }

    func reset() {
        strings.removeAll()
        datas.removeAll()
        saveError = nil
        getError = nil
        deleteError = nil
    }
}
