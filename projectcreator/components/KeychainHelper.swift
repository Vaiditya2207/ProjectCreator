//
//  KeychainHelper.swift
//  projectcreator
//
//  Created by Vaiditya Tanwar on 27/10/24.
//
import Foundation
import Security

class KeychainHelper {
    static let standard = KeychainHelper()
    
    func save(_ value: String, forKey key: String) {
        if let data = value.data(using: .utf8) {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecValueData: data
            ] as [String: Any]
            
            SecItemDelete(query as CFDictionary) // Delete old item if exists
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    func get(forKey key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &dataTypeRef) == noErr {
            if let data = dataTypeRef as? Data, let value = String(data: data, encoding: .utf8) {
                return value
            }
        }
        return nil
    }
    
    func read(forKey key: String) -> String? {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecReturnData as String: kCFBooleanTrue!,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var item: CFTypeRef?
            let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &item)
            
            if status == errSecSuccess {
                if let data = item as? Data {
                    return String(data: data, encoding: .utf8)
                }
            }
            
            return nil
        }
    
    
    func delete(forKey key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
    }
    
    func tokenExists(forKey key: String) -> Bool {
        return get(forKey: key) != nil
    }
}
