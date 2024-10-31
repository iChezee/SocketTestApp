import Foundation

public final class APIService: ObservableObject {
    private let keychainStore = AuthStore()
    private let urlScheme = "https"
    private let baseURLString = "platform.fintacharts.com"
    private let session = URLSession.shared
    
    public init() { }
    
    public func checkLogin() async -> Bool {
        if let username = keychainStore.get(key: .username),
           let password = keychainStore.get(key: .password) {
            let result = await getToken(username: username, password: password)
            return result
        } else {
            return false
        }
    }
    
    @discardableResult
    public func getToken(username: String, password: String) async -> Bool {
        guard let request = formTokenRequest(username: username, password: password) else {
            return false
        }
        
        do {
            let result = try await sendTokenRequest(request)
            if result {
                keychainStore.save(.credentials(username: username, password: password))
            }
            return try await sendTokenRequest(request)
        } catch(let error) {
            print(error)
            return false
        }
    }
    
    public func eraseCredentianl() {
        keychainStore.erase()
    }
}

// MARK: - Token stored
private extension APIService {
    var hostComponents: URLComponents {
        var components = URLComponents()
        components.scheme = urlScheme
        components.host = baseURLString
        
        return components
    }
    
    func formTokenRequest(username: String, password: String) -> URLRequest? {
        var components = hostComponents
        components.path = "/identity/realms/fintatech/protocol/openid-connect/token"
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "password"),
            URLQueryItem(name: "client_id", value: "app-cli"),
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "password", value: password)
        ]
        guard let url = components.url,
              let encodedBody = components.query?.data(using: .utf8) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodedBody
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Accept-Encoding" : "gzip, deflate, br",
            "Content-Length" : "\(encodedBody.count)"
        ]
        
        return request
    }
    
    func sendTokenRequest(_ request: URLRequest) async throws -> Bool {
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse,
           response.statusCode != 200 {
            let error = try JSONDecoder().decode(APIError.self, from: data)
            throw error
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        keychainStore.store(key: .token, value: tokenResponse.accessToken)
        keychainStore.store(key: .refreshToken, value: tokenResponse.accessToken)
        
        return true
    }
}

// MARK: - Objects fetch
extension APIService {
    @discardableResult
    public func fetchExchanges() async throws -> [ExchangeMarketDTO] {
        guard let exchangeDTO = try await fetchObjects(additionalPath: "exchanges", object: ExchangeDTO.self) else {
            return []
        }
        
        
        var objects: [ExchangeMarketDTO] = []
        for key in exchangeDTO.data.keys {
            let values = exchangeDTO.data[key]!
            let object = ExchangeMarketDTO(name: key, markets: values)
            objects.append(object)
        }
        print("Exchanges fetched. Total count: \(objects.count)")
        
        return objects
    }
    
    @discardableResult
    public func fetchInstruments(symbol: String? = nil, page: Int? = nil, size: Int? = nil) async throws -> (Int, [InstrumentDTO]) {
        guard var request = dtosRequest("instruments") else {
            return (0, [])
        }
        var items = [URLQueryItem]()
        if let symbol {
            items.append(URLQueryItem(name: "symbol", value: symbol))
        }
        
        if let page {
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        
        if let size {
            items.append(URLQueryItem(name: "size", value: "\(size)"))
        }
        var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
        components?.queryItems = items
        request.url = components?.url
        
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse,
           response.statusCode != 200 {
            throw GetObjectsError.unathorized
        }
        
        let instrumentsTotal = try JSONDecoder().decode(InstrumentsArrayDTO.self, from: data)
        
        return (instrumentsTotal.paging.items, instrumentsTotal.data)
    }
}

extension APIService {
    public func fetchObjects<T: Decodable>(additionalPath: String, object: T.Type) async throws -> T? {
        guard let request = dtosRequest(additionalPath) else {
            return nil
        }
        
        let (data, response) = try await session.data(for: request)
        if let response = response as? HTTPURLResponse,
           response.statusCode != 200 {
            throw GetObjectsError.unathorized
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func dtosRequest(_ additinalPath: String) -> URLRequest? {
        var components = hostComponents
        components.path.append("/api/instruments/v1/\(additinalPath)")
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(keychainStore.get(key: .token) ?? "")",
            "Accept-Encoding" : "gzip, deflate, br"
        ]
        
        return request
    }
}

private extension APIService {
    struct APIError: Error, Codable {
        let error: String
        let errorDescription: String
        
        enum CodingKeys: String, CodingKey {
            case error
            case errorDescription = "error_description"
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.error = try container.decode(String.self, forKey: CodingKeys.error)
            self.errorDescription = try container.decode(String.self, forKey: CodingKeys.errorDescription)
        }
        
        init(error: String, description: String) {
            self.error = error
            self.errorDescription = description
        }
    }
    
    struct TokenResponse: Codable {
        let accessToken: String
        let refreshToken: String
        let expire: Int
        let refreshExpire: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
            case expire = "expires_in"
            case refreshExpire = "refresh_expires_in"
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.accessToken = try container.decode(String.self, forKey: CodingKeys.accessToken)
            self.refreshToken = try container.decode(String.self, forKey: CodingKeys.refreshToken)
            self.expire = try container.decode(Int.self, forKey: CodingKeys.expire)
            self.refreshExpire = try container.decode(Int.self, forKey: CodingKeys.refreshExpire)
        }
    }
    
    enum GetObjectsError: Int, Error {
        case unathorized = 401
    }
}
