import SwiftUI
import Database

struct SearchForInstrumentView: View {
    @Binding var instruments: [Instrument]
    @Binding var selectedInstrument: Instrument?
    @Binding var instrumentName: String
    let subscribeAction: () -> Void
    
    var body: some View {
        HStack {
            TextField("Enter a currency", text: $instrumentName)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.black, lineWidth: 1)
                }
            Button {
                subscribeAction()
            } label: {
                Text(selectedInstrument != nil ? "Unsubscribe" : "Subscribe")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.black, lineWidth: 1)
            }
            .disabled(selectedInstrument == nil)
        }
        
    }
}
