//
//  FixMyLifeApp.swift
//  FixMyLife
//
//  Created by Khoa Nguyễn on 19/01/2026.
//

import SwiftUI
import SwiftData

@main
struct FixMyLifeApp: App {
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
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar) // Optional: cleaner look
        .defaultSize(width: 1000, height: 700)
        
        MenuBarExtra("RedoLife", systemImage: "leaf.fill") {
            Button("Mở ứng dụng") {
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first {
                    window.makeKeyAndOrderFront(nil)
                }
            }
            Divider()
            Button("Thoát") {
                NSApplication.shared.terminate(nil)
            }
        }
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
