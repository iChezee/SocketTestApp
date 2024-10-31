import SwiftData

@Model
final public class Provider: Equatable {
    @Attribute(.unique) public var name: String?
    public var symbol: String?
    @Relationship(deleteRule: .nullify) public var instruments: [Instrument]?
    
    
    public init(name: String, symbol: String? = nil) {
        self.name = name
        self.symbol = symbol
    }
}
