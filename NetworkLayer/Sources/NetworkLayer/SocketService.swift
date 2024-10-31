import Foundation
import Starscream

public protocol SocketServiceDelegate {
    func bidReceived(_ bid: Bid)
}

final public class SocketService {
    private let keychainStore = AuthStore()
    private var socket: WebSocket? = nil
    
    private let connection: Connection
    private let delegate: SocketServiceDelegate?
    
    public init(_ connection: Connection, delegate: SocketServiceDelegate? = nil) {
        self.connection = connection
        self.delegate = delegate
    }
    
    public func subscribe() {
        socket?.disconnect()
        socket = nil
        
        guard let request = buildSocketRequest() else {
            return
        }
        let socket = WebSocket(request: request)
        self.socket = socket
        socket.connect()
        socket.delegate = self
    }
    
    public func unsubscribe() {
        socket?.forceDisconnect()
        socket = nil
    }
    
    public func sendMessage(_ data: Data) {
        socket?.write(data: data)
    }
    
    public func sendPing(_ data: Data) {
        socket?.write(ping: data)
    }
    
    private func buildSocketRequest() -> URLRequest? {
        guard let token = keychainStore.get(key: .token),
              let url = URL(string: "wss://platform.fintacharts.com/api/streaming/ws/v1/realtime?token=\(token)") else {
            return nil
        }
        
        return URLRequest(url: url)
    }
}

extension SocketService: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(_):
            do {
                guard let data = try self.connection.toData() else {
                    return
                }
                self.socket?.write(data: data)
            } catch {
                
            }
        case .disconnected(let string, _):
            print("Socket disconnected: \(string)")
        case .text(let string):
            if let response = parseResponse(string, of: SocketResponse.self) {
                guard let bid = response.quote?.bid else {
                    return
                }
                delegate?.bidReceived(bid)
            } else if let response = parseResponse(string, of: StatusResponse.self) {
                print(response)
            }
        case .binary(let data):
            print(data)
        case .pong(let data):
            print("Pong: \(String(describing: data))")
        case .ping(let data):
            print("Ping: \(String(describing: data))")
        case .error(let error):
            print("Socket error: \(String(describing: error))")
        case .viabilityChanged(let bool):
            print("Visibility: \(bool)")
        case .reconnectSuggested(let bool):
            print("ReconnectSuggest: \(bool)")
        case .cancelled:
            print("Socket cancelled:")
        case .peerClosed:
            print("Socket peer closed")
        }
    }
    
    func parseResponse<T: Decodable>(_ string: String, of type: T.Type) -> T? {
        guard let data = string.data(using: .utf8),
              let object = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        
        return object
    }
}
