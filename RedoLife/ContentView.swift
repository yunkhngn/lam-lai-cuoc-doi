import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedTab: Tab = .dashboard
    @State private var isHoveringNew = false
    @State private var showingAddSheet = false
    @State private var newRoutineName = ""
    
    var body: some View {
        HStack(spacing: 0) {
            // Ultra-minimal Icon Sidebar
            VStack(spacing: 0) {
                // New button at top
                Button {
                    showingAddSheet = true
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
                        if tab != .settings {
                            IconButton(
                                icon: tab.icon,
                                isSelected: selectedTab == tab
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedTab = tab
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Settings at bottom
                IconButton(
                    icon: Tab.settings.icon,
                    isSelected: selectedTab == .settings
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = .settings
                    }
                }
                .padding(.bottom, 16)
            }
            .frame(width: 72)
            .background(AppColors.bgPrimary)
            
            // Main Content with transition
            ZStack {
                AppColors.bgPrimary.ignoresSafeArea()
                
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
                    case .settings:
                        SettingsView()
                    }
                }
                .transition(.opacity)
                .id(selectedTab)
            }
            .animation(.easeInOut(duration: 0.2), value: selectedTab)
        }
        .onAppear {
            viewModel.setContext(modelContext)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddRoutineSheetFromSidebar(name: $newRoutineName) {
                addRoutine()
            }
            .presentationDetents([.height(180)])
        }
    }
    
    func addRoutine() {
        guard !newRoutineName.isEmpty else { return }
        let routine = Routine(name: newRoutineName, order: viewModel.routines.count)
        modelContext.insert(routine)
        newRoutineName = ""
        showingAddSheet = false
        viewModel.fetchData()
    }
}

// MARK: - Add Routine Sheet
struct AddRoutineSheetFromSidebar: View {
    @Binding var name: String
    let onAdd: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Thêm thói quen")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            TextField("Tên thói quen", text: $name)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "1D1D1F"))
                .padding(16)
                .background(Color(hex: "F0F0F5"))
                .cornerRadius(12)
            
            HStack {
                Button("Huỷ") { dismiss() }
                    .foregroundStyle(AppColors.textMuted)
                
                Spacer()
                
                Button("Thêm") { onAdd() }
                    .disabled(name.isEmpty)
                    .foregroundStyle(name.isEmpty ? AppColors.textMuted : AppColors.green)
                    .fontWeight(.semibold)
            }
        }
        .padding(24)
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovering = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(isSelected ? AppColors.green : AppColors.mediumGray)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? AppColors.green.opacity(0.1) : (isHovering ? AppColors.lightGray.opacity(0.5) : Color.clear))
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Tab
enum Tab: CaseIterable, Hashable {
    case dashboard, calendar, goals, stats, settings
    
    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .calendar: return "calendar"
        case .goals: return "target"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape"
        }
    }
}

#Preview {
    ContentView()
        .environment(AppViewModel())
}
