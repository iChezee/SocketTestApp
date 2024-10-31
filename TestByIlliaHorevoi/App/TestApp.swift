import SwiftUI
import SwiftData
import NetworkLayer
import Database

@main
struct TestApp: App {
    let container: ModelContainer
    let apiService: APIService
    
    init() {
        container = Database.createContainer()
        apiService = APIService()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SplashView()
                    .modelContainer(container)
                    .modelContext(container.mainContext)
                    .environmentObject(apiService)
                    .preferredColorScheme(.light)
            }
        }
    }
}
