import SwiftUI
import SwiftData

struct MenuBarView: View {
    @Environment(AppViewModel.self) var viewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Streak & Progress
            HStack(spacing: 12) {
                // Streak Badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(viewModel.playerStats?.currentStreak ?? 0)")
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                
                Spacer()
                
                // Progress
                Text("\(Int(todayPercentage * 100))%")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(todayPercentage >= 1.0 ? AppColors.green : AppColors.textPrimary)
            }
            .padding(12)
            .background(Color.white)
            
            Divider()
            
            // Task List
            ScrollView {
                VStack(spacing: 0) {
                    if activeRoutines.isEmpty {
                        Text("Chưa có thói quen nào")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        ForEach(activeRoutines) { routine in
                            MenuBarRoutineRow(routine: routine, isDone: isDone(routine)) {
                                toggleRoutine(routine)
                            }
                            Divider() 
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
            
            Divider()
            
            // Footer Actions
            HStack {
                Button("Mở App") {
                    NSApp.activate(ignoringOtherApps: true)
                    if let window = NSApp.windows.first {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .onHover { _ in } // Fix button hover issue
                
                Spacer()
                
                Button("Thoát") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 280)
        .onAppear {
            viewModel.setContext(modelContext)
        }
    }
    
    // MARK: - Helpers
    var activeRoutines: [Routine] {
        viewModel.routines.filter { $0.isActive }.sorted { $0.order < $1.order }
    }
    
    var todayPercentage: Double {
        guard !activeRoutines.isEmpty else { return 0 }
        let completed = activeRoutines.filter { isDone($0) }.count
        return Double(completed) / Double(activeRoutines.count)
    }
    
    func isDone(_ routine: Routine) -> Bool {
        return viewModel.todayLogs[routine.id]?.isDone == true
    }
    
    func toggleRoutine(_ routine: Routine) {
        withAnimation {
            viewModel.toggleGlobalRoutine(routine, date: Date())
            viewModel.updateStats()
        }
    }
}

// MARK: - Row View
struct MenuBarRoutineRow: View {
    let routine: Routine
    let isDone: Bool
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    if isDone {
                        Circle()
                            .fill(AppColors.green)
                            .frame(width: 18, height: 18)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Circle()
                            .stroke(AppColors.mediumGray.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 18, height: 18)
                    }
                }
                
                Text(routine.name)
                    .strikethrough(isDone)
                    .foregroundStyle(isDone ? .secondary : AppColors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isHovering ? Color.black.opacity(0.05) : Color.clear)
        .onHover { isHovering = $0 }
    }
}
