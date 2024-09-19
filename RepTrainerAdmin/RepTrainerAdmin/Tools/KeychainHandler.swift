//
//  KeychainHandler.swift
//  LanguageChatAI
//
//  Created by Peter Pohlmann on 22/02/2024.
//

import Foundation

final class KeychainHandler {

  static let service = KeychainHandler()
  private init() {}

  func save(_ data: Data, service: String, account: String) {

    /// Create query
    let query = [
      kSecValueData: data,
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
    ] as CFDictionary

    /// Add data in query to keychain
    let status = SecItemAdd(query, nil)

    /// Update when write failed
    if status == errSecDuplicateItem {
      let query = [ /// Item already exist, thus update it.
        kSecAttrService: service,
        kSecAttrAccount: account,
        kSecClass: kSecClassGenericPassword,
      ] as CFDictionary

      let attributesToUpdate = [kSecValueData: data] as CFDictionary

      /// Update existing item
      _ = SecItemUpdate(query, attributesToUpdate)
    }

    if status != errSecSuccess {
      print("### Error: \(status)")
    }
  }

  func read(service: String, account: String) -> Data? {
    let query = [
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecClass: kSecClassGenericPassword,
      kSecReturnData: true
    ] as CFDictionary

    var result: AnyObject?
    SecItemCopyMatching(query, &result)

    return (result as? Data)
  }

  func delete(service: String, account: String) {
    let query = [
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecClass: kSecClassGenericPassword,
    ] as CFDictionary

    let status = SecItemDelete(query)
  }
}
