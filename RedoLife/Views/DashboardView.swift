import SwiftUI

struct DashboardView: View {
    @Environment(AppViewModel.self) var viewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(greetingText())
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Text(dateString())
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textMuted)
                }
                .padding(.top, 40)
                
                // Progress Card
                VStack(spacing: 24) {
                    let progress = calculateProgress()
                    
                    ZStack {
                        Circle()
                            .stroke(AppColors.lightGray, lineWidth: 10)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(AppColors.accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(duration: 0.6), value: progress)
                        
                        VStack(spacing: 4) {
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColors.textPrimary)
                        }
                    }
                    .frame(width: 100, height: 100)
                    
                    // Stats
                    HStack(spacing: 40) {
                        MiniStat(value: "\(viewModel.playerStats?.currentStreak ?? 0)", label: "Chuỗi ngày")
                        MiniStat(value: "\(viewModel.playerStats?.totalXP ?? 0)", label: "XP")
                    }
                }
                .frame(maxWidth: .infinity)
                .card()
                
                // Today's Routines
                VStack(alignment: .leading, spacing: 16) {
                    Text("Hôm nay")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textMuted)
                    
                    VStack(spacing: 0) {
                        ForEach(viewModel.routines.filter { $0.isActive }) { routine in
                            let isDone = viewModel.todayLogs[routine.id]?.isDone ?? false
                            
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.toggleRoutine(routine)
                                }
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 22))
                                        .foregroundStyle(isDone ? AppColors.green : AppColors.mediumGray.opacity(0.5))
                                    
                                    Text(routine.name)
                                        .font(.system(size: 16))
                                        .foregroundStyle(isDone ? AppColors.textMuted : AppColors.textPrimary)
                                        .strikethrough(isDone, color: AppColors.textMuted)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)
                            
                            if routine.id != viewModel.routines.filter({ $0.isActive }).last?.id {
                                Divider()
                                    .background(AppColors.lightGray)
                            }
                        }
                    }
                    .card(padding: 16)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Chào buổi sáng" }
        else if hour < 18 { return "Chào buổi chiều" }
        else { return "Chào buổi tối" }
    }
    
    func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: Date())
    }
    
    func calculateProgress() -> Double {
        let active = viewModel.routines.filter { $0.isActive }
        guard !active.isEmpty else { return 0 }
        let done = active.filter { viewModel.todayLogs[$0.id]?.isDone == true }.count
        return Double(done) / Double(active.count)
    }
}

struct MiniStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textMuted)
        }
    }
}

#Preview {
    DashboardView()
        .environment(AppViewModel())
}
