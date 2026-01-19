import SwiftUI

struct CalendarView: View {
    @Environment(AppViewModel.self) var viewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text(monthYearString(from: viewModel.currentMonth))
                        .roundedFont(.title2, weight: .bold)
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Days of Week Header
                HStack {
                    ForEach(0..<7, id: \.self) { index in
                        Text(weekdayString(from: Calendar.current.date(byAdding: .day, value: index, to: viewModel.currentDate) ?? Date())) // Simplified weekday logic
                            .roundedFont(.caption, weight: .bold)
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // Calendar Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                    ForEach(daysInMonth(), id: \.self) { date in
                        if let date = date {
                            let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
                            
                            VStack(spacing: 4) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .roundedFont(.body, weight: isToday ? .bold : .regular)
                                    .foregroundStyle(isToday ? AppColors.neonBlue : AppColors.textPrimary)
                                
                                // Dots for logs
                                HStack(spacing: 2) {
                                    if let logs = viewModel.monthlyLogs.values.compactMap({ $0[date.formatted(date: .numeric, time: .omitted)] }).filter({ $0.isDone }).prefix(3) {
                                        ForEach(0..<logs.count, id: \.self) { _ in
                                            Circle()
                                                .fill(AppColors.electricTeal)
                                                .frame(width: 4, height: 4)
                                        }
                                    }
                                }
                            }
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isToday ? AppColors.neonBlue.opacity(0.15) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isToday ? AppColors.neonBlue.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
                            )
                        } else {
                            Color.clear.frame(height: 50)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Legend
                GlassCard {
                    HStack {
                        Circle()
                            .fill(AppColors.electricTeal)
                            .frame(width: 8, height: 8)
                        Text("Hoàn thành")
                            .roundedFont(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Button("Hôm nay") {
                            withAnimation {
                                viewModel.currentMonth = Date()
                                viewModel.fetchMonthLogs(for: Date())
                            }
                        }
                        .foregroundStyle(AppColors.neonBlue)
                        .roundedFont(.caption, weight: .bold)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .background(AppGradients.deepLiquid.ignoresSafeArea())
        .onAppear {
            viewModel.fetchMonthLogs(for: viewModel.currentMonth)
        }
    }
    
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: date)
    }

    func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: date)
    }
    
    func daysInMonth() -> [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: viewModel.currentMonth),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.currentMonth)) else {
            return []
        }
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: viewModel.currentMonth) {
            viewModel.fetchMonthLogs(for: newDate)
        }
    }
}
