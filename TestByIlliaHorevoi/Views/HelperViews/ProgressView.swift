import SwiftUI

struct SplashProgress: View {
    @Binding var currentProgress: Double
    @State var total: Double = 100
    
    var body: some View {
        ProgressView(value: currentProgress, total: total)
            .progressViewStyle(
                LinearProgressViewStyle(tint: .gray.opacity(0.8))
            )
            .background(.white)
            .padding(.top, 200)
            .padding(.horizontal, 50)
            .task {
                while currentProgress < total - 20 {
                    withAnimation {
                        currentProgress += 10.0
                    }
                    await Task.sleep(0.1)
                }
            }
    }
}
