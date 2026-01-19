import SwiftUI

// MARK: - Inspiration Quotes (easy to edit)
let inspirationQuotes: [String] = [
    "Hôm nay cậu vẫn còn đứng dậy\nlà vẫn có thể bước tiếp.",
    "Không cần tốt hơn ai cả.\nChỉ cần cậu không bỏ cuộc.",
    "Nếu cậu thấy mệt,\nchậm lại chút cũng được.",
    "Mọi việc nhỏ hôm nay\nđều có ý nghĩa lớn.",
    "Không sao cả nếu hôm nay của cậu không ổn.",
    "Chỉ cần cố thêm chút thôi.\nCố gắng lên nhé!",
    "Cậu đang không lạc hướng.\nHãy cố gắng nhé!",
    "Hôm nay cậu chưa ổn\nkhông có nghĩa là mai cũng vậy."
]

struct DashboardView: View {
    @Environment(AppViewModel.self) var viewModel
    @AppStorage("userName") private var userName: String = ""
    
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
                
                // Progress Card - Split Layout (4:6 ratio)
                ZStack {
                    // Bubble gradient background
                    GeometryReader { bgGeo in
                        // Top right bubble - bigger
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [AppColors.accent.opacity(0.2), AppColors.accent.opacity(0)],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 180
                                )
                            )
                            .frame(width: 360, height: 360)
                            .offset(x: bgGeo.size.width - 180, y: -100)
                        
                        // Bottom left bubble - bigger
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [AppColors.green.opacity(0.15), AppColors.green.opacity(0)],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 140
                                )
                            )
                            .frame(width: 280, height: 280)
                            .offset(x: -100, y: bgGeo.size.height - 100)
                        
                        // Center accent bubble - bigger
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.purple.opacity(0.12), Color.purple.opacity(0)],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .offset(x: bgGeo.size.width * 0.5, y: bgGeo.size.height * 0.2)
                    }
                    
                    // Content
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            // Left: Progress Circle (40%)
                            VStack(spacing: 20) {
                                let progress = calculateProgress()
                                
                                ZStack {
                                    Circle()
                                        .stroke(AppColors.lightGray.opacity(0.5), lineWidth: 12)
                                    Circle()
                                        .trim(from: 0, to: progress)
                                        .stroke(
                                            LinearGradient(
                                                colors: [AppColors.accent, AppColors.accent.opacity(0.7)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                        )
                                        .rotationEffect(.degrees(-90))
                                        .animation(.spring(duration: 0.6), value: progress)
                                    
                                    VStack(spacing: 2) {
                                        Text("\(Int(progress * 100))%")
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .foregroundStyle(AppColors.textPrimary)
                                    }
                                }
                                .frame(width: 130, height: 130)
                                
                                // Stats
                                HStack(spacing: 28) {
                                    MiniStat(value: "\(viewModel.playerStats?.currentStreak ?? 0)", label: "Chuỗi")
                                    MiniStat(value: "\(viewModel.playerStats?.totalXP ?? 0)", label: "XP")
                                }
                            }
                            .frame(width: geo.size.width * 0.4)
                            .frame(maxHeight: .infinity)
                            
                            // Divider
                            Rectangle()
                                .fill(AppColors.lightGray.opacity(0.5))
                                .frame(width: 1)
                                .padding(.vertical, 32)
                            
                            // Right: Inspiration Quote (60%)
                            VStack {
                                Spacer()
                                
                                VStack(spacing: 16) {
                                    Text("❝")
                                        .font(.system(size: 56, weight: .bold))
                                        .foregroundStyle(AppColors.accent.opacity(0.15))
                                    
                                    Text(randomQuote())
                                        .font(.system(size: 22, weight: .medium, design: .serif))
                                        .foregroundStyle(AppColors.textPrimary)
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(6)
                                        .padding(.horizontal, 20)
                                }
                                
                                Spacer()
                            }
                            .frame(width: geo.size.width * 0.6)
                        }
                    }
                }
                .frame(height: 280)
                .card(padding: 0)
                
                // Today's Routines
                VStack(alignment: .leading, spacing: 16) {
                    Text("Hôm nay")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textMuted)
                    
                    let activeRoutines = viewModel.routines.filter { $0.isActive }
                    
                    if activeRoutines.isEmpty {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(AppColors.accent.opacity(0.3))
                            
                            Text("Chưa có thói quen nào")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundStyle(AppColors.textPrimary)
                            
                            Text("Nhấn nút + để bắt đầu\nhành trình của bạn")
                                .font(.system(size: 14))
                                .foregroundStyle(AppColors.textMuted)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .card(padding: 20)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(activeRoutines) { routine in
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
                                
                                if routine.id != activeRoutines.last?.id {
                                    Divider()
                                        .background(AppColors.lightGray)
                                }
                            }
                        }
                        .card(padding: 16)
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greeting: String
        if hour < 12 { greeting = "Chào buổi sáng" }
        else if hour < 18 { greeting = "Chào buổi chiều" }
        else { greeting = "Chào buổi tối" }
        
        if userName.isEmpty {
            return greeting
        } else {
            return "\(greeting), \(userName)"
        }
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
    
    func randomQuote() -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return inspirationQuotes[dayOfYear % inspirationQuotes.count]
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
