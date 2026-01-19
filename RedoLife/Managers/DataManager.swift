import Foundation
import SwiftData

class DataManager {
    static let shared = DataManager()
    
    let modelContainer: ModelContainer
    
    init() {
        let schema = Schema([
            Routine.self,
            DailyLog.self,
            PlayerStats.self,
            Goal.self
        ])
        
        // Try to create container, if migration fails, delete old data
        do {
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {

            print("Migration failed: \(error). Deleting old data...")
            
            // Delete the old database files
            let fileManager = FileManager.default
            if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let storeURL = appSupport.appendingPathComponent("default.store")
                try? fileManager.removeItem(at: storeURL)
                
                // Also try to remove any related files
                let storeSHM = appSupport.appendingPathComponent("default.store-shm")
                let storeWAL = appSupport.appendingPathComponent("default.store-wal")
                try? fileManager.removeItem(at: storeSHM)
                try? fileManager.removeItem(at: storeWAL)
            }
            
            // Retry creating container
            do {
                let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after cleanup: \(error)")
            }
        }
    }
}
