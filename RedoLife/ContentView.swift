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
        case dashboard = "Tổng quan"
        case calendar = "Lịch sử"
        case goals = "Mục tiêu"
        case stats = "Thống kê"
        
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
                Label {
                    Text(tab.rawValue)
                        .roundedFont(.body, weight: .medium)
                } icon: {
                    Image(systemName: tab.icon)
                }
                .tag(tab)
                .listRowBackground(selectedTab == tab ? AppColors.warmOrange.opacity(0.15) : Color.clear)
                .listRowSeparator(.hidden)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
            .background(AppColors.sidebarBG)
        } detail: {
            ZStack {
                AppGradients.deepLiquid.ignoresSafeArea()
                
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
                    Text("Chọn một mục")
                        .roundedFont(.title)
                }
            }
        }
        .onAppear {
            appViewModel.setContext(modelContext)
        }
        .background(AppGradients.deepLiquid) // Fallback
    }
}

#Preview {
    ContentView()
        .environment(AppViewModel())
        // Mock data container would go here
}

