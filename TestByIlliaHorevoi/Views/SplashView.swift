// Made by Illia Horevoi

import SwiftUI
import NetworkLayer

struct SplashView: View {
    @EnvironmentObject var apiService: APIService
    @State var navigateNext: Bool?
    
    @State var currentProgress: Double = 0
    var body: some View {
        VStack {
            Group {
                Text("Initializing application")
                    .font(.title)
                SplashProgress(currentProgress: $currentProgress)
            }
            .foregroundStyle(.black)
        }
        .task {
            let isLoggedIn = await apiService.checkLogin()
            Task { @MainActor in
                withAnimation {
                    currentProgress = 100
                }
                await Task.sleep(0.5)
                navigateNext = isLoggedIn
            }
        }
        .navigationDestination(item: $navigateNext) { value in
            if value {
                MainView(apiService)
                    .environmentObject(apiService)
            } else {
                LoginView()
            }
        }
    }
}
