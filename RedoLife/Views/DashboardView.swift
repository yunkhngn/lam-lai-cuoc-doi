import SwiftUI

struct DashboardView: View {
    @Environment(AppViewModel.self) var viewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText())
                        .roundedFont(.largeTitle, weight: .bold)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(dateString())
                        .roundedFont(.subheadline)
                        .foregroundStyle(AppColors.textMuted)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Progress Card
                VStack(spacing: 16) {
                    let progress = calculateProgress()
                    
                    // Progress Ring
                    ZStack {
                        Circle()
                            .stroke(AppColors.lightSage, lineWidth: 12)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(AppColors.accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(duration: 0.5), value: progress)
                        
                        VStack(spacing: 2) {
                            Text("\(Int(progress * 100))%")
                                .roundedFont(.title, weight: .bold)
                                .foregroundStyle(AppColors.textPrimary)
                            Text("hoàn thành")
                                .roundedFont(.caption)
                                .foregroundStyle(AppColors.textMuted)
                        }
                    }
                    .frame(width: 120, height: 120)
                    
                    // Stats Row
                    HStack(spacing: 32) {
                        StatItem(icon: "flame.fill", value: "\(viewModel.playerStats?.currentStreak ?? 0)", label: "Chuỗi", color: AppColors.tan)
                        StatItem(icon: "star.fill", value: "\(viewModel.playerStats?.totalXP ?? 0)", label: "XP", color: AppColors.sage)
                    }
                }
                .frame(maxWidth: .infinity)
                .card(padding: 24)
                .padding(.horizontal)
                
                // Today's Routines
                VStack(alignment: .leading, spacing: 12) {
                    Text("Thói quen hôm nay")
                        .roundedFont(.headline, weight: .semibold)
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        ForEach(viewModel.routines.filter { $0.isActive }) { routine in
                            let isDone = viewModel.todayLogs[routine.id]?.isDone ?? false
                            
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.toggleRoutine(routine)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: routine.icon)
                                        .font(.title3)
                                        .foregroundStyle(isDone ? AppColors.forest : AppColors.sage)
                                        .frame(width: 32)
                                    
                                    Text(routine.name)
                                        .roundedFont(.body)
                                        .foregroundStyle(isDone ? AppColors.sage : AppColors.textPrimary)
                                        .strikethrough(isDone, color: AppColors.sage)
                                    
                                    Spacer()
                                    
                                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundStyle(isDone ? AppColors.forest : AppColors.lightSage)
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(isDone ? AppColors.forest.opacity(0.08) : Color.clear)
                            }
                            .buttonStyle(.plain)
                            
                            if routine.id != viewModel.routines.filter({ $0.isActive }).last?.id {
                                Divider()
                                    .background(AppColors.lightSage)
                            }
                        }
                    }
                    .background(AppColors.bgCard)
                    .cornerRadius(16)
                    .shadow(color: AppColors.forest.opacity(0.05), radius: 8, y: 4)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 40)
        }
        .background(AppColors.bgPrimary.ignoresSafeArea())
    }
    
    // MARK: - Helpers
    func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Chào buổi sáng," }
        else if hour < 18 { return "Chào buổi chiều," }
        else { return "Chào buổi tối," }
    }
    
    func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd/MM/yyyy"
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

// MARK: - Stat Item
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(value)
                    .roundedFont(.title2, weight: .bold)
                    .foregroundStyle(AppColors.textPrimary)
            }
            Text(label)
                .roundedFont(.caption)
                .foregroundStyle(AppColors.textMuted)
        }
    }
}

#Preview {
    DashboardView()
        .environment(AppViewModel())
}
