//
//  La_m_la_i_cuo__c__o__iApp.swift
//  Làm lại cuộc đời
//
//  Created by Khoa Nguyễn on 19/01/2026.
//

import SwiftUI
import SwiftData

@main
struct La_m_la_i_cuo__c__o__iApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
