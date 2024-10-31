import Foundation

struct SocketResponse: Decodable {
    let type: String
    let instrumentId: String
    let provider: String
    let quote: Quote?
}

struct Quote: Decodable {
    let bid: Bid?
    
    enum CodingKeys: String, CodingKey {
        case bid
        case last
        case ask
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let last = try container.decodeIfPresent(Bid.self, forKey: .last) {
            self.bid = last
        } else if let ask = try container.decodeIfPresent(Bid.self, forKey: .ask) {
            self.bid = ask
        } else {
            self.bid = try container.decodeIfPresent(Bid.self, forKey: .bid)
        }
    }
}

public struct Bid: Decodable {
    public let timestamp: String
    public let price: Double
    public let volume: Int
    public let change: Double?
    
    public func convertTime() -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime]
        
        return isoFormatter.date(from: timestamp)
    }
    
    public func timeToString() -> String? {
        guard let date = convertTime() else {
            return ""
        }
        let dateFormmater = DateFormatter()
        dateFormmater.dateFormat = "YYYY-MM-dd, hh:mm:ss"
        return dateFormmater.string(from: date)
    }
}

struct StatusResponse: Decodable {
    let type: String
    let requestId: String?
    let sessionId: String?
}
