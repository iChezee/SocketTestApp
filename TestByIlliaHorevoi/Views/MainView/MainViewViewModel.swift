import Foundation
import NetworkLayer
import Database
import SwiftUI

final class MainViewViewModel: ObservableObject {
    @Published var instrumentName = "" {
        didSet {
            if instrumentName != selectedInstrument?.symbol && !instrumentName.isEmpty {
                instruments = []
                searchForInstruments()
            }
        }
    }
    @Published var instruments: [Instrument] = [] {
        willSet {
            if instruments != newValue {
                showChooseInstrument = true
            }
        }
    }
    @Published var selectedInstrument: Instrument? {
        didSet {
            instrumentName = selectedInstrument?.symbol ?? ""
            page = 1
            instruments = []
            isFinished = true
            socketService?.unsubscribe()
            pingTask?.cancel()
            pingTask = nil
            socketService = nil
            bids.removeAll()
            lastBid = nil
            subscribeToInstrument()
        }
    }
    @Published var page: Int = 1
    @Published var isFinished = false
    @Published var newSearch = true
    
    @Published var timer: DispatchWorkItem?
    @Published var showChooseInstrument = false
    @Published var downloadMoreToggle = false {
        didSet {
            if downloadMoreToggle {
                searchForInstruments()
            }
        }
    }
    
    @Published var bids = [Bid]()
    @Published var lastBid: Bid?
    
    @Published var eraseSheet = false
    
    private let apiService: APIService
    private var socketService: SocketService?
    private var pingTask: Task<Void, Never>?
    private var downloadTask: Task<Void, Never>?
    
    init(_ apiService: APIService) {
        self.apiService = apiService
    }
    
    func searchForInstruments() {
        timer?.cancel()
        downloadTask?.cancel()
        downloadTask = nil
        let timer = DispatchWorkItem { [unowned self] in
            self.downloadTask = Task(priority: .background) { [unowned self] in
                do {
                    let (totalItems, result) = try await self.apiService.fetchInstruments(symbol: self.instrumentName, page: self.page, size: 20)
                    
                    var objects = [Instrument]()
                    for instrument in result {
                        let providers = instrument.mappings.compactMap { Provider.create(with: $0)}
                        let object = Instrument(id: instrument.id, symbol: instrument.symbol, kind: instrument.kind, providers: providers)
                        objects.append(object)
                    }
                    
                    await MainActor.run {
                        self.page += 1
                        self.isFinished = totalItems % 20 >= self.page
                        
                        withAnimation {
                            self.instruments.append(contentsOf: objects)
                            self.downloadMoreToggle = false
                            self.showChooseInstrument = true
                        }
                    }
                } catch(let error) {
                    print(error)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: timer)
        self.timer = timer
    }
    
    func eraseCredentials() {
        apiService.eraseCredentianl()
    }
    
    func handleConnection() {
        guard socketService != nil else {
            subscribeToInstrument()
            return
        }
        
        unsubscribeFromInstrument()
    }
}

private extension MainViewViewModel {
    func subscribeToInstrument() {
        guard let selectedInstrument else {
            return
        }
        
        let connection = Connection(instrument: selectedInstrument)
        let socket = SocketService(connection, delegate: self)
        socketService = socket
        socket.subscribe()
        createPingTask()
    }
    
    func unsubscribeFromInstrument() {
        socketService?.unsubscribe()
        pingTask?.cancel()
        pingTask = nil
        socketService = nil
        selectedInstrument = nil
        bids.removeAll()
        lastBid = nil
    }
    
    func createPingTask() {
        pingTask = Task(priority: .background) {
            while(true) {
                await Task.sleep(5)
                socketService?.sendPing(Data())
            }
        }
    }
}

extension MainViewViewModel: SocketServiceDelegate {
    func bidReceived(_ bid: Bid) {
        bids.append(bid)
        lastBid = bid
        objectWillChange.send()
    }
}
