import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedTab: Tab = .dashboard
    
    var body: some View {
        HStack(spacing: 0) {
            // Custom Sidebar
            VStack(alignment: .leading, spacing: 8) {
                // App Title
                Text("Làm lại cuộc đời")
                    .roundedFont(.headline, weight: .bold)
                    .foregroundStyle(AppColors.forest)
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                
                // Navigation Items
                ForEach(Tab.allCases, id: \.self) { tab in
                    SidebarItem(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        selectedTab = tab
                    }
                }
                
                Spacer()
            }
            .frame(width: 200)
            .background(AppColors.cream)
            
            // Divider
            Rectangle()
                .fill(AppColors.lightSage)
                .frame(width: 1)
            
            // Detail View
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .calendar:
                    CalendarView()
                case .goals:
                    GoalsView()
                case .stats:
                    StatsView()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(AppColors.bgPrimary)
        .onAppear {
            viewModel.setContext(modelContext)
        }
    }
}

// MARK: - Sidebar Item
struct SidebarItem: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 24)
                
                Text(tab.title)
                    .roundedFont(.body, weight: isSelected ? .semibold : .regular)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? AppColors.offWhite : (isHovering ? AppColors.forest : AppColors.sage))
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AppColors.forest : (isHovering ? AppColors.forest.opacity(0.1) : Color.clear))
            )
            .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Tab
enum Tab: CaseIterable, Hashable {
    case dashboard, calendar, goals, stats
    
    var title: String {
        switch self {
        case .dashboard: return "Tổng quan"
        case .calendar: return "Lịch sử"
        case .goals: return "Mục tiêu"
        case .stats: return "Thống kê"
        }
    }
    
    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .calendar: return "calendar"
        case .goals: return "target"
        case .stats: return "chart.bar.fill"
        }
    }
}

#Preview {
    ContentView()
        .environment(AppViewModel())
}
