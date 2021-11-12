//
//  KeychainPersistence.swift
//  Sensory Cloud
//
//  Created by Niles Hacking on 11/3/21.
//

import Foundation

class KeychainPersistence {

    /// Saves a string to the Apple Keychain
    ///
    /// - Parameters:
    ///   - id: Keychain id to save under
    ///   - string: String to save to Apple Keychain
    func save(id: String, string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        try save(id: id, data: data)
    }

    /// Saves data to the Apple Keychain
    ///
    /// - Parameters:
    ///   - id: Keychain id to save under
    ///   - data: Data to save to Apple Keychain
    func save(id: String, data: Data) throws {
        try delete(id: id)
        NSLog("Saving item to keychain with tag: %@", id)

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrApplicationTag as String: id,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError.saveError(status)
        }
    }

    /// Fetches data from the Apple Keychain and attempts to convert it to a string using `.utf8` encoding
    ///
    /// This function will throw `KeychainError.itemNotFound` if no data is found for the specified keychain id
    /// - Parameter id: Keychain id to fetch data for
    /// - Returns: Data found in Apple Keychain converted to a String
    func getString(id: String) throws -> String {
        let data = try getData(id: id)
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.decodingError
        }
        return string
    }

    /// Fetches data from the Apple Keychain
    ///
    /// This function will throw `KeychainError.itemNotFound` if no data is found for the specified keychain id
    /// - Parameter id: Keychain id to fetch data for
    /// - Returns: Data found in Apple Keychain
    func getData(id: String) throws -> Data {
        NSLog("Getting item from keychain with tag: %@", id)

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: id,
            kSecReturnData as String: true
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data, status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound(id)
            }
            throw KeychainError.getError(status)
        }
        return data
    }

    /// Deletes an item from the Apple Keychain
    ///
    /// - Parameter id: Keychain id to delete data for
    func delete(id: String) throws {
        NSLog("Deleting item from keychain with tag: %@", id)

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: id
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.deleteError(status)
        }
    }
}
