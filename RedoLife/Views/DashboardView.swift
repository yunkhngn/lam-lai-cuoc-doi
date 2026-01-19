import SwiftUI

struct DashboardView: View {
    @Environment(AppViewModel.self) var viewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Area
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(currentDateString())
                            .roundedFont(.subheadline, weight: .medium)
                            .foregroundStyle(AppColors.textSecondary)
                        
                        Text("Chào bạn,")
                            .roundedFont(.largeTitle, weight: .bold)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Bento Grid Layout
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 20)], spacing: 20) {
                    
                    // 1. Main Stats Card (Wide)
                    GlassCard {
                        HStack(spacing: 0) {
                            // Progress Ring
                            let activeRoutines = viewModel.routines.filter { $0.isActive }
                            let completedToday = activeRoutines.filter { viewModel.todayLogs[$0.id]?.isDone == true }.count
                            let progress = activeRoutines.isEmpty ? 0 : Double(completedToday) / Double(activeRoutines.count)
                            
                            VStack {
                                ProgressCircleView(progress: progress)
                                    .frame(width: 80, height: 80)
                                    .padding(.bottom, 8)
                                Text("\(Int(progress * 100))% Hoàn thành")
                                    .roundedFont(.caption, weight: .bold)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            // Metrics
                            VStack(alignment: .leading, spacing: 20) {
                                StatRow(icon: "flame.fill", value: "\(viewModel.playerStats?.currentStreak ?? 0)", label: "Chuỗi ngày", color: AppColors.warmOrange)
                                StatRow(icon: "star.fill", value: "\(viewModel.playerStats?.totalXP ?? 0)", label: "Tổng XP", color: AppColors.softPurple)
                            }
                            .padding(.leading, 30)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 10)
                    }
                    .frame(height: 180)
                    
                    // 2. Focus / Routine Cards
                    ForEach(viewModel.routines.filter { $0.isActive }) { routine in
                        let isDone = viewModel.todayLogs[routine.id]?.isDone ?? false
                        
                        RoutineGridCard(routine: routine, isDone: isDone) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.toggleRoutine(routine)
                            }
                        }
                    }
                    
                    // 3. Add New Placeholder (Optional, triggers navigation or popover)
                    NavigationLink(destination: GoalsView()) {
                        GlassCard {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.largeTitle)
                                    .foregroundStyle(AppColors.textSecondary)
                                Text("Thêm thói quen")
                                    .roundedFont(.body)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(height: 140) // Match RoutineGridCard height
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .background(AppGradients.deepLiquid.ignoresSafeArea())
    }
    
    func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: viewModel.currentDate)
    }
}

// New Grid Card for Routines
struct RoutineGridCard: View {
    let routine: Routine
    let isDone: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            GlassCard(padding: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: routine.icon)
                            .font(.title2)
                            .foregroundStyle(isDone ? AppColors.electricTeal : AppColors.textPrimary)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(isDone ? AppColors.electricTeal.opacity(0.2) : Color.white.opacity(0.05))
                            )
                        Spacer()
                        
                        if isDone {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.electricTeal)
                        } else {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                .frame(width: 20, height: 20)
                        }
                    }
                    
                    Text(routine.name)
                        .roundedFont(.title3, weight: .semibold)
                        .foregroundStyle(isDone ? AppColors.textSecondary : AppColors.textPrimary)
                        .strikethrough(isDone)
                        .lineLimit(2)
                }
            }
        }
        .buttonStyle(.plain)
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
                    .roundedFont(.title3, weight: .bold)
                Text(label)
                    .roundedFont(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    DashboardView()
        .environment(AppViewModel())
}
