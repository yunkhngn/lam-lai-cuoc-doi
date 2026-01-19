import SwiftUI
import Charts

struct StatsView: View {
    @Environment(AppViewModel.self) var viewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Tiến độ của bạn")
                    .roundedFont(.largeTitle, weight: .bold)
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                // Stats Cards
                HStack(spacing: 12) {
                    StatCard(
                        icon: "flame.fill",
                        color: AppColors.tan,
                        value: "\(viewModel.playerStats?.currentStreak ?? 0)",
                        label: "Chuỗi"
                    )
                    StatCard(
                        icon: "trophy.fill",
                        color: AppColors.sage,
                        value: "\(viewModel.playerStats?.bestStreak ?? 0)",
                        label: "Chuỗi tốt nhất"
                    )
                    StatCard(
                        icon: "star.fill",
                        color: AppColors.forest,
                        value: "\(viewModel.playerStats?.totalXP ?? 0)",
                        label: "Tổng XP"
                    )
                }
                .padding(.horizontal)
                
                // Chart
                VStack(alignment: .leading, spacing: 12) {
                    Text("7 ngày qua (% hoàn thành)")
                        .roundedFont(.headline, weight: .semibold)
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Chart {
                        ForEach(last7DaysData(), id: \.date) { item in
                            BarMark(
                                x: .value("Ngày", item.date, unit: .day),
                                y: .value("Hoàn thành", item.percentage)
                            )
                            .foregroundStyle(AppColors.forest.gradient)
                            .cornerRadius(4)
                        }
                    }
                    .chartYScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(AppColors.lightSage)
                            AxisValueLabel(format: .dateTime.day())
                                .foregroundStyle(AppColors.textMuted)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(AppColors.lightSage)
                            AxisValueLabel {
                                if let intVal = value.as(Int.self) {
                                    Text("\(intVal)%")
                                        .roundedFont(.caption)
                                        .foregroundStyle(AppColors.textMuted)
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                }
                .card()
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.bottom, 40)
        }
        .background(AppColors.bgPrimary.ignoresSafeArea())
    }
    
    // MARK: - Data
    func last7DaysData() -> [DayData] {
        let calendar = Calendar.current
        var data: [DayData] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                data.append(DayData(date: date, percentage: Double.random(in: 0...100)))
            }
        }
        
        return data.reversed()
    }
}

struct DayData {
    let date: Date
    let percentage: Double
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let color: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .roundedFont(.title, weight: .bold)
                .foregroundStyle(AppColors.textPrimary)
            
            Text(label)
                .roundedFont(.caption)
                .foregroundStyle(AppColors.textMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

#Preview {
    StatsView()
        .environment(AppViewModel())
}
