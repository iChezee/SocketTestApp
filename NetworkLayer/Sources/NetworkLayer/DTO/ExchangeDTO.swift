struct ExchangeDTO: Decodable {
    let data: [String: [String]]
}

public struct ExchangeMarketDTO: Decodable {
    public let name: String
    public let markets: [String]
}
