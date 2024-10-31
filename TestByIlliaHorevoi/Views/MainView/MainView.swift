import SwiftUI
import SwiftData
import NetworkLayer
import Database
import Charts

struct MainView: View {
    @EnvironmentObject var apiService: APIService
    @ObservedObject var viewModel: MainViewViewModel
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    init(_ apiService: APIService) {
        viewModel = MainViewViewModel(apiService)
    }
    
    var body: some View {
        VStack {
            search
            if viewModel.showChooseInstrument {
                dropdown
            } else {
                lastBidInfo
                priceChart
            }
            Spacer()
        }
        .padding(20)
        .navigationBarBackButtonHidden()
        .task {
            await downloadObjects()
        }
        .navigationBarItems(leading: eraseButton)
        .confirmationDialog("", isPresented: $viewModel.eraseSheet, actions: {
            Button("Yes", role: .destructive) {
                viewModel.eraseCredentials()
                dismiss.callAsFunction()
            }
        }, message: {
            Text("Are you sure want to delete everuthing?")
        })
    }
    
    var eraseButton: some View {
        Button {
            viewModel.eraseSheet.toggle()
        } label: {
            Text("X")
        }
    }
    
    var search: some View {
        SearchForInstrumentView(instruments: $viewModel.instruments,
                                selectedInstrument: $viewModel.selectedInstrument,
                                instrumentName: $viewModel.instrumentName,
                                subscribeAction: viewModel.handleConnection)
    }
    
    var dropdown: some View {
        ChooseInstrumentDropdown(instruments: $viewModel.instruments,
                                 selectedEInstrument: $viewModel.selectedInstrument,
                                 downloadMoreToggle: $viewModel.downloadMoreToggle,
                                 isFinished: $viewModel.isFinished,
                                 showView: $viewModel.showChooseInstrument)
        .padding(.leading)
    }
    
    @ViewBuilder
    var lastBidInfo: some View {
        if let symbol = viewModel.selectedInstrument?.symbol,
           let bid = viewModel.lastBid {
            LastBidView(selectedSymbol: symbol, bid: bid)
        }
    }
    
    var priceChart: some View {
        Chart {
            ForEach(viewModel.bids, id: \.timestamp) { bid in
                LineMark(x: .value("Date", bid.convertTime() ?? Date()),
                         y: .value("Price", bid.price))
                .foregroundStyle(.blue)
            }
        }
    }
}

extension MainView {
    func downloadObjects() async {
        do {
            for dto in try await apiService.fetchExchanges() {
                let object = Exchange(name: dto.name, markets: dto.markets)
                context.insert(object)
            }
            
            try context.save()
        } catch {
            print(error)
        }
    }
}
