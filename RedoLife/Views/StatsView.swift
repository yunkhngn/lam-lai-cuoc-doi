import SwiftUI
import Charts

struct StatsView: View {
    @Environment(AppViewModel.self) var viewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                HStack {
                    Text("Tiến độ của bạn")
                        .roundedFont(.largeTitle, weight: .bold)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Key Metrics
                HStack(spacing: 16) {
                    StatCard(title: "Chuỗi", value: "\(viewModel.playerStats?.currentStreak ?? 0)", icon: "flame.fill", color: .orange)
                    StatCard(title: "Chuỗi tốt nhất", value: "\(viewModel.playerStats?.bestStreak ?? 0)", icon: "trophy.fill", color: .yellow)
                    StatCard(title: "Tổng XP", value: "\(viewModel.playerStats?.totalXP ?? 0)", icon: "star.fill", color: .purple)
                }
                .padding(.horizontal)
                
                // Weekly Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("7 ngày qua (% hoàn thành)")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart {
                        ForEach(getLast7Days(), id: \.self) { date in
                            let dateKey = date.formatted(date: .numeric, time: .omitted)
                            // Aggregate logs manually for now since monthlyLogs is populated by default for 'today's month'
                            // Ideally fetch exact data range.
                            // Simplified for responsiveness: Just show mock or derived if unavailable.
                            // We will reuse monthlyLogs if available or 0.
                            let value = getCompletionPercent(for: date)
                            
                            BarMark(
                                x: .value("Ngày", date, unit: .day),
                                y: .value("Hoàn thành", value * 100)
                            )
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple], startPoint: .bottom, endPoint: .top)
                            )
                            .cornerRadius(4)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Material.regular)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .onAppear {
            // Ideally fetch stats for wider range
            viewModel.fetchMonthLogs(for: Date())
        }
    }
    
    func getLast7Days() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).map {
            calendar.date(byAdding: .day, value: -$0, to: today)!
        }.reversed()
    }
    
    func getCompletionPercent(for date: Date) -> Double {
        let dateKey = date.formatted(date: .numeric, time: .omitted)
        let activeRoutines = viewModel.routines.filter { $0.isActive }
        guard !activeRoutines.isEmpty else { return 0 }
        
        var completed = 0
        for routine in activeRoutines {
            if let logs = viewModel.monthlyLogs[routine.id], let log = logs[dateKey], log.isDone {
                completed += 1
            }
        }
        
        return Double(completed) / Double(activeRoutines.count)
    }
}

// Replaced StatCard with Glass version
struct StatCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    Text(title)
                        .roundedFont(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(value)
                    .roundedFont(.title2, weight: .bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
