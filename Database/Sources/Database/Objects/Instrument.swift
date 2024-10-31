import SwiftData

@Model
final public class Instrument: Equatable {
    @Attribute(.unique) public var id: String
    public var symbol: String
    public var kind: String
    @Relationship(deleteRule: .nullify) public var providers: [Provider]
    
    public init(id: String, symbol: String, kind: String, providers: [Provider]) {
        self.id = id
        self.symbol = symbol
        self.kind = kind
        self.providers = providers
    }
}
