import Foundation
import Security

struct AuthStore: AuthorizationStore {
    static var tokenKey: String { "com.illiahorevoi.socketTest.storedToken" }
    static var refreshTokenKey: String { "com.illiahorevoi.socketTest.refreshToken" }
    static var usernameKey: String { "com.illiahorevoi.socketTest.username" }
    static var passwordKey: String { "com.illiahorevoi.socketTest.password" }
    private var serviceName = "SocketTest"
    
    func store(key: AuthorizationKey, value: String) {
        save(Data(value.utf8), account: key.representant(for: Self.self))
    }
    
    func remove(key: AuthorizationKey) {
        delete(account: key.representant(for: Self.self))
    }
    
    func get(key: AuthorizationKey) -> String? {
        guard let data = read(account: key.representant(for: Self.self)) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func save(_ value: AuthorizationValue) {
        switch value {
        case .token(let value):
            store(key: .token, value: value)
            
        case .refreshToken(let value):
            store(key: .refreshToken, value: value)
            
        case .credentials(let username, let password):
            store(key: .username, value: username)
            store(key: .password, value: password)
            
        case .value(let value, let key):
            store(key: .raw(key), value: value)
        }
    }
    
    func erase() {
        remove(key: .username)
        remove(key: .password)
        remove(key: .token)
        remove(key: .refreshToken)
    }
    
    private func save(_ data: Data, account: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: serviceName
        ] as CFDictionary
        let saveStatus = SecItemAdd(query, nil)
        if saveStatus == errSecDuplicateItem { update(data, account: account) }
    }
    
    private func update(_ data: Data, account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: serviceName
        ] as CFDictionary
        let updatedData = [kSecValueData: data] as CFDictionary
        
        SecItemUpdate(query, updatedData)
    }
    
    private func read(account: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecAttrService: serviceName
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return result as? Data
    }
    
    private func delete(account: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecAttrService: serviceName
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}
