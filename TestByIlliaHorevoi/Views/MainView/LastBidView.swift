import NetworkLayer
import SwiftUI

struct LastBidView: View {
    let selectedSymbol: String
    let bid: Bid
    
    var body: some View {
        VStack {
            HStack {
                Text("Market data:")
                Spacer()
            }
            
            HStack {
                symbol
                Spacer()
                price
                Spacer()
                time
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(.black)
            .padding(20)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.black, lineWidth: 1)
            }
        }
    }
    
    var symbol: some View {
        VStack {
            Text("Symbol:")
            Text(selectedSymbol)
        }
    }
    
    var price: some View {
        VStack {
            Text("Price:")
            Text("$ \(String(format: "%.2f", bid.price))")
        }
    }
    
    var time: some View {
        VStack {
            Text("Time:")
            Text(bid.timeToString() ?? "")
        }
    }
}
