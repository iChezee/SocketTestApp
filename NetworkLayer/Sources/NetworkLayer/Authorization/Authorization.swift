import Foundation

protocol AuthorizationStore {
    static var tokenKey: String { get }
    static var refreshTokenKey: String { get }
    static var usernameKey: String { get }
    static var passwordKey: String { get }
    
    func get(key: AuthorizationKey) -> String?
    func save(_ value: AuthorizationValue)
    func remove(key: AuthorizationKey)
    func erase()
    
    func store(key: AuthorizationKey, value: String)
}


enum AuthorizationKey {
    case token, refreshToken, username, password
    case raw(_ key: String)
    
    public func representant<Store: AuthorizationStore>(for type: Store.Type) -> String {
        switch self {
        case .token:
            return Store.tokenKey
        case .refreshToken:
            return Store.refreshTokenKey
        case .username:
            return Store.usernameKey
        case .password:
            return Store.passwordKey
        case .raw(let key):
            return key
        }
    }
}

enum AuthorizationValue {
    case token(_ value: String)
    case refreshToken(_ value: String)
    case credentials(username: String, password: String)
    
    case value(_ value: String, key: String)
}
