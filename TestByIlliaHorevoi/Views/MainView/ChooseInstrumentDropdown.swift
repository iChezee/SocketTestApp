import SwiftUI
import Database

struct ChooseInstrumentDropdown: View {
    @Binding var instruments: [Instrument]
    @Binding var selectedEInstrument: Instrument?
    @Binding var downloadMoreToggle: Bool
    @Binding var isFinished: Bool
    @Binding var showView: Bool
    
    @State var selectedObjectName = ""
    
    let cellSize: CGFloat = 36
    
    var body: some View {
        if showView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Color.clear.frame(maxWidth: .infinity, maxHeight: 1)
                    ForEach(instruments) { item in
                        if selectedEInstrument != item {
                            HideableCellView(tab: item,
                                             selectedEditor: $selectedEInstrument,
                                             showView: $showView)
                            .onAppear {
                                if item == instruments.last {
                                    downloadMoreToggle = true
                                }
                            }
                        }
                    }
                    
                    if !isFinished {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.black)
                            .foregroundColor(.red)
                    }
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
}

struct HideableCellView: View {
    var tab: Instrument
    @Binding var selectedEditor: Instrument?
    @Binding var showView: Bool
    var selected: Bool {
        tab == selectedEditor
    }
    
    let cellSize: CGFloat = 36
    
    var body: some View {
        Button {
            withAnimation {
                selectedEditor = tab
                showView.toggle()
            }
        } label: {
            HStack(spacing: 0) {
                Text(tab.symbol)
                    .foregroundStyle(.black)
                    .font(.system(size: 16))
                Spacer()
            }
        }
        .frame(height: cellSize)
        .frame(maxWidth: .infinity)
        .background(selected ? .black.opacity(0.1) : .white)
    }
}
