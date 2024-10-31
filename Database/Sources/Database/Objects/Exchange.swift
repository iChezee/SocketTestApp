import SwiftData

@Model
final public class Exchange: Equatable {
    @Attribute(.unique) public var name: String
    @Relationship(deleteRule: .nullify) public var markets: [Market]
    
    public init(name: String, markets: [String]) {
        self.name = name
        self.markets = [Market]()
        for market in markets {
            self.markets.append(Market(name: market, exchange: self))
        }
    }
}

@Model
public final class Market {
    @Attribute(.unique) public var name: String
    @Relationship(deleteRule: .nullify, inverse: \Exchange.markets)public  var exchange: [Exchange]
    
    public init(name: String, exchange: Exchange) {
        self.name = name
        self.exchange = [Exchange]()
        self.exchange.append(exchange)
    }
}
