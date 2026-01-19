import SwiftUI

struct CalendarView: View {
    @Environment(AppViewModel.self) var viewModel
    
    private let weekdays = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(AppColors.textMuted)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(monthYearString())
                    .roundedFont(.title2, weight: .bold)
                    .foregroundStyle(AppColors.textPrimary)
                
                Spacer()
                
                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundStyle(AppColors.textMuted)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Weekday Header
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .roundedFont(.caption, weight: .semibold)
                        .foregroundStyle(AppColors.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid
            let days = generateCalendarDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days.indices, id: \.self) { index in
                    let day = days[index]
                    
                    if let date = day {
                        let isToday = Calendar.current.isDateInToday(date)
                        let dayNum = Calendar.current.component(.day, from: date)
                        
                        Text("\(dayNum)")
                            .roundedFont(.body, weight: isToday ? .bold : .regular)
                            .foregroundStyle(isToday ? AppColors.offWhite : AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(isToday ? AppColors.forest : Color.clear)
                            )
                    } else {
                        Color.clear
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Today Button
            HStack {
                Circle()
                    .fill(AppColors.forest)
                    .frame(width: 8, height: 8)
                Text("Hoàn thành")
                    .roundedFont(.caption)
                    .foregroundStyle(AppColors.textMuted)
                
                Spacer()
                
                Button("Hôm nay") {
                    withAnimation {
                        viewModel.currentMonth = Date()
                        viewModel.fetchMonthLogs(for: Date())
                    }
                }
                .roundedFont(.subheadline, weight: .semibold)
                .foregroundStyle(AppColors.forest)
            }
            .padding()
            .background(AppColors.bgCard)
            .cornerRadius(16)
            .shadow(color: AppColors.forest.opacity(0.05), radius: 8, y: 4)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(AppColors.bgPrimary.ignoresSafeArea())
        .onAppear {
            viewModel.fetchMonthLogs(for: viewModel.currentMonth)
        }
    }
    
    // MARK: - Helpers
    func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: viewModel.currentMonth)
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
