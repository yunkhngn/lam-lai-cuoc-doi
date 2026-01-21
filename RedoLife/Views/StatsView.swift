import SwiftUI
import Charts

struct StatsView: View {
    @Environment(AppViewModel.self) var viewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                Text("Thống kê")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.top, 40)
                
                // Stats Cards
                HStack(spacing: 16) {
                    StatCard(value: "\(viewModel.playerStats?.currentStreak ?? 0)", label: "Chuỗi ngày")
                    StatCard(value: "\(viewModel.playerStats?.bestStreak ?? 0)", label: "Kỷ lục")
                    StatCard(value: "\(viewModel.playerStats?.totalXP ?? 0)", label: "Tổng XP")
                }
                
                // Activity Heatmap
                VStack(alignment: .leading, spacing: 16) {
                    Text("Hoạt động")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    ActivityHeatmap(logs: viewModel.last90DaysLogs)
                }
                .card()
                
                // Weekly Trend
                VStack(alignment: .leading, spacing: 16) {
                    Text("7 ngày qua")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Chart {
                        ForEach(calculateLast7DaysData(), id: \.date) { item in
                            BarMark(
                                x: .value("Ngày", item.date, unit: .day),
                                y: .value("Hoàn thành", item.percentage)
                            )
                            .foregroundStyle(AppColors.green.gradient)
                            .cornerRadius(4)
                        }
                    }
                    .chartYScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisValueLabel(format: .dateTime.weekday(.narrow))
                                .foregroundStyle(AppColors.textMuted)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                                .foregroundStyle(AppColors.lightGray)
                            AxisValueLabel()
                                .foregroundStyle(AppColors.textMuted)
                        }
                    }
                    .frame(height: 180)
                }
                .card()
                
                // Mood Trend (Removed)
                
                // Top Routines
                VStack(alignment: .leading, spacing: 16) {
                    Text("Top thói quen")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    let sortedStats = viewModel.routineStats.values.sorted { $0.completionCount > $1.completionCount }.prefix(5)
                    
                    if sortedStats.isEmpty {
                        Text("Chưa có dữ liệu")
                            .foregroundStyle(AppColors.textMuted)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        VStack(spacing: 24) {
                            // Donut Chart
                            Chart(Array(sortedStats.enumerated()), id: \.element.name) { index, stat in
                                SectorMark(
                                    angle: .value("Count", stat.completionCount),
                                    innerRadius: .ratio(0.6),
                                    angularInset: 2
                                )
                                .cornerRadius(5)
                                .foregroundStyle(getPieColor(index: index))
                            }
                            .frame(height: 220)
                            
                            // Legend
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                                ForEach(Array(sortedStats.enumerated()), id: \.element.name) { index, stat in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(getPieColor(index: index))
                                            .frame(width: 8, height: 8)
                                        
                                        Text(stat.name)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(AppColors.textPrimary)
                                            .lineLimit(1)
                                        
                                        Text("(\(stat.completionCount))")
                                            .font(.system(size: 12))
                                            .foregroundStyle(AppColors.textMuted)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .card()
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(AppColors.bgPrimary.ignoresSafeArea())
        .onAppear {
            viewModel.fetchActivityData()
        }
    }
    
    func calculateLast7DaysData() -> [DayData] {
        let calendar = Calendar.current
        var data: [DayData] = []
        
        let activeRoutines = viewModel.routines.filter { $0.isActive }
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -6 + i, to: Date()) {
                let dateKey = calendar.startOfDay(for: date).formatted(date: .numeric, time: .omitted)
                
                var completedCount = 0
                if !activeRoutines.isEmpty {
                    for routine in activeRoutines {
                        if let log = viewModel.last7DaysLogs[routine.id]?[dateKey], log.isDone {
                            completedCount += 1
                        }
                    }
                }
                
                let total = max(1, activeRoutines.count)
                let percentage = Double(completedCount) / Double(total) * 100
                data.append(DayData(date: date, percentage: percentage))
            }
        }
        
        return data
    }
}

struct ActivityHeatmap: View {
    let logs: [Date: [DailyLog]]
    
    let rows = 7 // Mon, Tue, Wed, Thu, Fri, Sat, Sun
    let spacing: CGFloat = 4
    let boxSize: CGFloat = 12
    
    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { proxy in
                    HStack(spacing: spacing) {
                        // Calculate weeks
                        let calendar = Calendar.current
                        let today = calendar.startOfDay(for: Date())
                
                        
                        ForEach(0..<53, id: \.self) { weekIndex in
                            VStack(spacing: spacing) {
                                ForEach(0..<rows, id: \.self) { dayIndex in
                    
                                    if let date = getDate(weekIndex: weekIndex, dayIndex: dayIndex, today: today) {
                                        if date <= today {
                                            let count = logs[date]?.count ?? 0
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(getColor(count: count))
                                                .frame(width: boxSize, height: boxSize)
                                        } else {
                                            // Future dates hidden or placeholder
                                            Color.clear
                                                .frame(width: boxSize, height: boxSize)
                                        }
                                    } else {
                                        Color.clear
                                            .frame(width: boxSize, height: boxSize)
                                    }
                                }
                            }
                            .id(weekIndex)
                        }
                    }
                    .padding(.horizontal, 4) // Inner padding
                    .onAppear {
                         // Scroll to end (latest week)
                         proxy.scrollTo(52, anchor: .trailing)
                    }
                }
            }
            .frame(height: (boxSize * CGFloat(rows)) + (spacing * CGFloat(rows - 1)))
            
            // Legend
            HStack(spacing: 4) {
                Text("Ít")
                    .font(.system(size: 10))
                    .foregroundStyle(AppColors.textMuted)
                
                ForEach(0..<5) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(getColorForLegend(level: level))
                        .frame(width: 10, height: 10)
                }
                
                Text("Nhiều")
                    .font(.system(size: 10))
                    .foregroundStyle(AppColors.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 4)
        }
    }
    
    func getDate(weekIndex: Int, dayIndex: Int, today: Date) -> Date? {
        let calendar = Calendar.current
        // Strategy: simplified
        // Week 52 is current week.
        // weekIndex 0 is 52 weeks ago.
        
        let currentWeekDay = calendar.component(.weekday, from: today) // 1 (Sun) to 7 (Sat)
        // Convert to 0 (Mon) - 6 (Sun) for our grid
        let todayDayIndex = (currentWeekDay + 5) % 7
        
        // Calculate offset in days from today
        // weekDiff = weekIndex - 52
        let weeksDiff = weekIndex - 52
        let daysDiff = (weeksDiff * 7) + (dayIndex - todayDayIndex)
        
        return calendar.date(byAdding: .day, value: daysDiff, to: today)
    }
    
    func getColor(count: Int) -> Color {
        if count == 0 { return AppColors.lightGray.opacity(0.5) }
        if count == 1 { return AppColors.green.opacity(0.3) }
        if count == 2 { return AppColors.green.opacity(0.5) }
        if count == 3 { return AppColors.green.opacity(0.7) }
        return AppColors.green
    }
    
    func getColorForLegend(level: Int) -> Color {
        switch level {
        case 0: return AppColors.lightGray.opacity(0.5)
        case 1: return AppColors.green.opacity(0.3)
        case 2: return AppColors.green.opacity(0.5)
        case 3: return AppColors.green.opacity(0.7)
        default: return AppColors.green
        }
    }
}

func getPieColor(index: Int) -> Color {
    let colors = [
        Color(hex: "FFB3BA"), // Pastel Pink
        Color(hex: "BAFFC9"), // Pastel Mint
        Color(hex: "BAE1FF"), // Pastel Blue
        Color(hex: "FFDFD3"), // Pastel Peach
        Color(hex: "E0BBE4"), // Pastel Purple
        Color(hex: "FFFFBA"), // Pastel Yellow
        Color(hex: "D291BC"), // Pastel Mauve
        Color(hex: "957DAD")  // Pastel Violet
    ]
    return colors[index % colors.count]
}

func getRankColor(index: Int) -> Color {
    switch index {
    case 0: return Color(hex: "FFD700") // Gold
    case 1: return Color(hex: "C0C0C0") // Silver
    case 2: return Color(hex: "CD7F32") // Bronze
    default: return AppColors.green
    }
}

struct DayData {
    let date: Date
    let percentage: Double
}

struct StatCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    StatsView()
        .environment(AppViewModel())
}
