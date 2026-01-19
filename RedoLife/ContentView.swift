import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedTab: Tab = .dashboard
    @State private var isHoveringNew = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Ultra-minimal Icon Sidebar
            VStack(spacing: 0) {
                // New button at top
                Button {
                    // Add new routine action
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppColors.darkGray)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(isHoveringNew ? AppColors.lightGray : AppColors.white)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                        )
                }
                .buttonStyle(.plain)
                .onHover { isHoveringNew = $0 }
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                // Nav Icons
                VStack(spacing: 8) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        IconButton(
                            icon: tab.icon,
                            isSelected: selectedTab == tab
                        ) {
                            selectedTab = tab
                        }
                    }
                }
                
                Spacer()
            }
            .frame(width: 72)
            .background(AppColors.bgPrimary)
            
            // Main Content
            ZStack {
                AppColors.bgPrimary.ignoresSafeArea()
                
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
        }
        .onAppear {
            viewModel.setContext(modelContext)
        }
    }
}

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(isSelected ? AppColors.accent : AppColors.mediumGray)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? AppColors.accent.opacity(0.1) : (isHovering ? AppColors.lightGray.opacity(0.5) : Color.clear))
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}

// MARK: - Tab
enum Tab: CaseIterable, Hashable {
    case dashboard, calendar, goals, stats
    
    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .calendar: return "calendar"
        case .goals: return "checkmark.circle"
        case .stats: return "chart.bar.fill"
        }
    }
}

#Preview {
    ContentView()
        .environment(AppViewModel())
}
