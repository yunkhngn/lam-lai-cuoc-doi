//
//  La_m_la_i_cuo__c__o__iApp.swift
//  Làm lại cuộc đời
//
//  Created by Khoa Nguyễn on 19/01/2026.
//

import SwiftUI
import SwiftData

@main
struct RedoLifeApp: App {
    let dataManager = DataManager.shared
    @State private var appViewModel = AppViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appViewModel)
                .preferredColorScheme(.light)
        }
        .modelContainer(dataManager.modelContainer)
        
        MenuBarExtra("Làm lại cuộc đời", systemImage: "flame.fill") {
            MenuBarView()
                .environment(appViewModel)
        }
        .menuBarExtraStyle(.window)
        .onChange(of: scenePhase) { _, newPhase in
             if newPhase == .active {
                 // Refresh logical day if needed
                 appViewModel.fetchData()
             }
        }
    }
    
    init() {
        NotificationManager.shared.requestPermission()
    }
}
