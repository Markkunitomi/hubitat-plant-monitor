import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    private let service = "com.github.hubitat-plant-monitor"
    
    private init() {}
    
    func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            try update(key: key, data: data)
        } else if status != errSecSuccess {
            throw AppError.keychainError("Failed to save item with status: \(status)")
        }
    }
    
    func save(key: String, string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw AppError.keychainError("Failed to convert string to data")
        }
        try save(key: key, data: data)
    }
    
    private func update(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        guard status == errSecSuccess else {
            throw AppError.keychainError("Failed to update item with status: \(status)")
        }
    }
    
    func load(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw AppError.keychainError("Item not found")
            } else {
                throw AppError.keychainError("Failed to load item with status: \(status)")
            }
        }
        
        guard let data = result as? Data else {
            throw AppError.keychainError("Failed to convert result to data")
        }
        
        return data
    }
    
    func loadString(key: String) throws -> String {
        let data = try load(key: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw AppError.keychainError("Failed to convert data to string")
        }
        return string
    }
    
    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppError.keychainError("Failed to delete item with status: \(status)")
        }
    }
    
    func exists(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}

extension KeychainHelper {
    private enum Keys {
        static let apiToken = "hubitat_api_token"
    }
    
    func saveAPIToken(_ token: String) throws {
        try save(key: Keys.apiToken, string: token)
    }
    
    func loadAPIToken() throws -> String {
        return try loadString(key: Keys.apiToken)
    }
    
    func deleteAPIToken() throws {
        try delete(key: Keys.apiToken)
    }
    
    func hasAPIToken() -> Bool {
        return exists(key: Keys.apiToken)
    }
}