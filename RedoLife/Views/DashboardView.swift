import SwiftUI

struct DashboardView: View {
    @Environment(AppViewModel.self) var viewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.currentDate.formatted(date: .complete, time: .omitted))
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Today's Focus")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                .padding(.top)
                
                // Stats Card
                HStack(spacing: 32) {
                    // Progress Circle
                    let activeRoutines = viewModel.routines.filter { $0.isActive }
                    let completedCount = activeRoutines.filter { viewModel.todayLogs[$0.id]?.isDone == true }.count
                    let totalCount = activeRoutines.count
                    let progress = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
                    
                    ProgressCircleView(progress: progress)
                    
                    // Stats Text
                    VStack(alignment: .leading, spacing: 12) {
                        StatRow(icon: "flame.fill", value: "\(viewModel.playerStats?.currentStreak ?? 0)", label: "Day Streak", color: .orange)
                        StatRow(icon: "star.fill", value: "\(viewModel.playerStats?.totalXP ?? 0)", label: "Total XP", color: .yellow)
                        StatRow(icon: "chart.line.uptrend.xyaxis", value: "Lvl \(viewModel.playerStats?.level ?? 1)", label: "Current Level", color: .blue)
                    }
                    Spacer()
                }
                .padding()
                .background(Material.ultraThin)
                .cornerRadius(16)
                
                // Routine List
                VStack(spacing: 12) {
                    if viewModel.routines.isEmpty {
                        ContentUnavailableView("No Routines Yet", systemImage: "list.bullet.clipboard", description: Text("Go to Goals to add some habits."))
                    } else {
                        ForEach(viewModel.routines.filter { $0.isActive }) { routine in
                            let isDone = viewModel.todayLogs[routine.id]?.isDone ?? false
                            RoutineRowView(routine: routine, isDone: isDone) {
                                withAnimation {
                                    viewModel.toggleRoutine(routine)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct StatRow: View {
    var icon: String
    var value: String
    var label: String
    var color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 20)
            VStack(alignment: .leading) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    DashboardView()
        .environment(AppViewModel())
}
