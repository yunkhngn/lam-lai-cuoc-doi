import Foundation
import SwiftData

class DataManager {
    static let shared = DataManager()
    
    let modelContainer: ModelContainer
    
    init() {
        let schema = Schema([
            Routine.self,
            DailyLog.self,
            PlayerStats.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
