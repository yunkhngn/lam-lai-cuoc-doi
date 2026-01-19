import SwiftUI

struct CalendarView: View {
    @Environment(AppViewModel.self) var viewModel
    
    private let weekdays = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.textMuted)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(monthYearString())
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                
                Spacer()
                
                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.textMuted)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 40)
            
            // Calendar Card
            VStack(spacing: 20) {
                // Weekday Header
                HStack {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppColors.textMuted)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar Grid
                let days = generateCalendarDays()
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                    ForEach(days.indices, id: \.self) { index in
                        let day = days[index]
                        
                        if let date = day {
                            let isToday = Calendar.current.isDateInToday(date)
                            let dayNum = Calendar.current.component(.day, from: date)
                            
                            Text("\(dayNum)")
                                .font(.system(size: 15, weight: isToday ? .semibold : .regular))
                                .foregroundStyle(isToday ? .white : AppColors.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(isToday ? AppColors.accent : Color.clear)
                                )
                        } else {
                            Color.clear
                                .frame(width: 36, height: 36)
                        }
                    }
                }
            }
            .card()
            
            Spacer()
        }
        .padding(.horizontal, 40)
        .background(AppColors.bgPrimary.ignoresSafeArea())
        .onAppear {
            viewModel.fetchMonthLogs(for: viewModel.currentMonth)
        }
    }
    
    func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: viewModel.currentMonth).capitalized
    }
    
    func generateCalendarDays() -> [Date?] {
        let calendar = Calendar.current
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.currentMonth)),
              let range = calendar.range(of: .day, in: .month, for: viewModel.currentMonth) else {
            return []
        }
        
        var firstWeekday = calendar.component(.weekday, from: monthStart)
        firstWeekday = (firstWeekday + 5) % 7
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        
        return days
    }
    
    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: viewModel.currentMonth) {
            viewModel.currentMonth = newDate
            viewModel.fetchMonthLogs(for: newDate)
        }
    }
}

#Preview {
    CalendarView()
        .environment(AppViewModel())
}
