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
                
                // Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("7 ngày qua")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.textMuted)
                    
                    Chart {
                        ForEach(calculateLast7DaysData(), id: \.date) { item in
                            BarMark(
                                x: .value("Ngày", item.date, unit: .day),
                                y: .value("Hoàn thành", item.percentage)
                            )
                            .foregroundStyle(AppColors.accent.gradient)
                            .cornerRadius(6)
                        }
                    }
                    .chartYScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: .dateTime.day())
                                .foregroundStyle(AppColors.textMuted)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(height: 180)
                }
                .card()
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(AppColors.bgPrimary.ignoresSafeArea())
        .onAppear {
            viewModel.fetchLast7DaysLogs()
        }
    }
    
    func calculateLast7DaysData() -> [DayData] {
        let calendar = Calendar.current
        var data: [DayData] = []
        
        let activeRoutines = viewModel.routines.filter { $0.isActive }
        guard !activeRoutines.isEmpty else {
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -6 + i, to: Date()) {
                    data.append(DayData(date: date, percentage: 0))
                }
            }
            return data
        }
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -6 + i, to: Date()) {
                let dateKey = calendar.startOfDay(for: date).formatted(date: .numeric, time: .omitted)
                
                var completedCount = 0
                for routine in activeRoutines {
                    if let log = viewModel.last7DaysLogs[routine.id]?[dateKey], log.isDone {
                        completedCount += 1
                    }
                }
                
                let percentage = Double(completedCount) / Double(activeRoutines.count) * 100
                data.append(DayData(date: date, percentage: percentage))
            }
        }
        
        return data
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
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

#Preview {
    StatsView()
        .environment(AppViewModel())
}
