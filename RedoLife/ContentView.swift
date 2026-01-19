//
//  ContentView.swift
//  Làm lại cuộc đời
//
//  Created by Khoa Nguyễn on 19/01/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppViewModel.self) var appViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedTab: Tab? = .dashboard
    
    enum Tab: String, CaseIterable, Identifiable {
        case dashboard = "Overview"
        case calendar = "History"
        case goals = "Routines"
        case stats = "Insights"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .calendar: return "calendar"
            case .goals: return "list.bullet.clipboard"
            case .stats: return "chart.bar.xaxis"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(Tab.allCases, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            .listStyle(.sidebar)
        } detail: {
            switch selectedTab {
            case .dashboard:
                DashboardView()
            case .calendar:
                CalendarView()
            case .goals:
                GoalsView()
            case .stats:
                StatsView()
            case nil:
                Text("Select an item")
            }
        }
        .onAppear {
            appViewModel.setContext(modelContext)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppViewModel())
        // Mock data container would go here
}

