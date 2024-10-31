import SwiftData
import Foundation

public struct Connection: Encodable {
    public var id: String
    public var type: String
    public var instrumentID: String
    public var provider: String
    public var isSubscribed: Bool
    public var kinds: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case instrumentID = "instrumentId"
        case provider
        case isSubscribed = "subscribe"
        case kinds = "kind"
    }
    
    public init(id: String = "1", type: String = "l1-subscription", instrumentID: String, provider: String, isSubscribed: Bool) {
        self.id = id
        self.type = type
        self.instrumentID = instrumentID
        self.provider = provider
        self.isSubscribed = isSubscribed
        self.kinds = Kind.allCases.map { $0.rawValue }
    }
    
    public func toData() throws -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        do {
            return try encoder.encode(self)
        } catch {
            print(error)
            return nil
        }
    }
}

extension Connection {
    public enum Kind: String, CaseIterable {
        case ask
        case last
        case bid
    }
}
