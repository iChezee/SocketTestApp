import Foundation
import SwiftData

public struct Database {
    public static func createContainer() -> ModelContainer {
        do {
            let schema = Schema([Provider.self, Exchange.self, Instrument.self])
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let configuration = ModelConfiguration(schema: schema, url: url.appending(path: "db.sqlite"), allowsSave: true)
            let container =  try ModelContainer(for: Provider.self, Exchange.self, Instrument.self, configurations: configuration)
            
            return container
        } catch {
            fatalError("Cannot create container")
        }
    }
}
