import Foundation

struct InstrumentsArrayDTO: Decodable {
    let paging: InstrumentsPage
    let data: [InstrumentDTO]
}

struct InstrumentsPage: Decodable {
    let page: Int
    let pages: Int
    let items: Int
}

public struct InstrumentDTO: Decodable {
    public let id: String
    public let symbol: String
    public let kind: String
    public let mappings: [MappingDTO]
    
    enum CodingKeys: CodingKey {
        case id
        case symbol
        case kind
        case mappings
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.kind = try container.decode(String.self, forKey: .kind)
        
        let decodedMappings = try container.decode([String: NestedMappingDTO].self, forKey: .mappings)
        var mappings = [MappingDTO]()
        for key in decodedMappings.keys {
            guard let nestedObject = decodedMappings[key] else {
                continue
            }
            let object = MappingDTO(name: key, symbol: nestedObject.symbol, exchange: nestedObject.exchange)
            mappings.append(object)
        }
        self.mappings = mappings
    }
}

public struct NestedMappingDTO: Decodable {
    public var symbol: String
    public var exchange: String
}

public struct MappingDTO {
    public var name: String
    public var symbol: String
    public var exchange: String
    
    init(name: String, symbol: String, exchange: String) {
        self.name = name
        self.symbol = symbol
        self.exchange = exchange
    }
}
