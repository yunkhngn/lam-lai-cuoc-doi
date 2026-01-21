import SwiftUI

struct CalendarView: View {
    @Environment(AppViewModel.self) var viewModel
    
    @State private var selectedDate: Date? = nil
    
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
                            DayCell(
                                date: date,
                                completionPercentage: getCompletionForDate(date),
                                isToday: Calendar.current.isDateInToday(date),
                                isSelected: selectedDate != nil && Calendar.current.isDate(date, inSameDayAs: selectedDate!)
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedDate = date
                                }
                            }
                        } else {
                            Color.clear
                                .frame(width: 36, height: 36)
                        }
                    }
                }
                
                // Legend
                HStack(spacing: 24) {
                    LegendItem(color: AppColors.green, label: "Hoàn thành")
                    LegendItem(color: AppColors.green.opacity(0.5), label: "Một phần")
                    LegendItem(color: AppColors.lightGray, label: "Chưa làm")
                }
                .padding(.top, 8)
            }
            .card()
            
            // Selected Day Details
            if let date = selectedDate {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(formatSelectedDate(date))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColors.textMuted)
                        
                        Spacer()
                        
                        Button {
                            withAnimation { selectedDate = nil }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppColors.textMuted)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    let dateKey = Calendar.current.startOfDay(for: date).formatted(date: .numeric, time: .omitted)
                    let checkDate = Calendar.current.startOfDay(for: date)
                    
                    // Robust filter: 
                    // 1. routine.isActive -> Show
                    // 2. hasLog -> Show (Always show history if data exists)
                    // 3. !isActive AND archivedAt != nil AND date < startOfDay(archivedAt) -> Show (Show history before it was archived)
                    let routinesToShow = viewModel.routines.filter { routine in
                        // Check explicit log existence
                        if viewModel.monthlyLogs[routine.id]?[dateKey] != nil { return true }
                        
                        // If active, show
                        if routine.isActive { return true }
                        
                        // If archived: Check if this date is BEFORE the archive date
                        if let archivedDate = routine.archivedAt {
                             let archiveStartDay = Calendar.current.startOfDay(for: archivedDate)
                             return checkDate < archiveStartDay
                        }
                        
                        return false
                    }
                    
                    if routinesToShow.isEmpty {
                        Text("Chưa có thói quen nào")
                            .foregroundStyle(AppColors.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        VStack(spacing: 0) {
                            ForEach(routinesToShow, id: \.id) { routine in
                                let isDone = viewModel.monthlyLogs[routine.id]?[dateKey]?.isDone ?? false
                                
                                HStack(spacing: 12) {
                                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(isDone ? AppColors.green : AppColors.mediumGray.opacity(isDone ? 1 : 0.4))
                                    
                                    Text(routine.name)
                                        .foregroundStyle(isDone ? AppColors.textPrimary : AppColors.textMuted)
                                    
                                    Spacer()
                                    
                                    if !routine.isActive {
                                        Image(systemName: "archivebox.fill")
                                            .font(.system(size: 10))
                                            .foregroundStyle(AppColors.textMuted.opacity(0.5))
                                    }
                                }
                                .padding(.vertical, 10)
                                
                                if routine.id != routinesToShow.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .card(padding: 16)
                    }
                }
            }
            
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
    
    func formatSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: date).capitalized
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
    
    func getCompletionForDate(_ date: Date) -> Double {
        let calendar = Calendar.current
        let dateKey = calendar.startOfDay(for: date).formatted(date: .numeric, time: .omitted)
        let checkDate = calendar.startOfDay(for: date)
        
        let validRoutines = viewModel.routines.filter { routine in
            if viewModel.monthlyLogs[routine.id]?[dateKey] != nil { return true }
            if routine.isActive { return true }
            if let archivedDate = routine.archivedAt {
                 return checkDate < calendar.startOfDay(for: archivedDate)
            }
            return false
        }
        
        guard !validRoutines.isEmpty else { return 0 }
        
        var completedCount = 0
        for routine in validRoutines {
            if let log = viewModel.monthlyLogs[routine.id]?[dateKey], log.isDone {
                completedCount += 1
            }
        }
        
        return Double(completedCount) / Double(validRoutines.count)
    }
    
    func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: viewModel.currentMonth) {
            viewModel.currentMonth = newDate
            viewModel.fetchMonthLogs(for: newDate)
            selectedDate = nil
        }
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let completionPercentage: Double
    let isToday: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        let dayNum = Calendar.current.component(.day, from: date)
        
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(dayNum)")
                    .font(.system(size: 15, weight: isToday ? .semibold : .regular))
                    .foregroundStyle(isToday ? .white : (isSelected ? AppColors.green : AppColors.textPrimary))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isToday ? AppColors.green : (isSelected ? AppColors.green.opacity(0.1) : Color.clear))
                    )
                
                // Completion indicator dot
                Circle()
                    .fill(dotColor)
                    .frame(width: 6, height: 6)
                    .opacity(completionPercentage > 0 ? 1 : 0.3)
            }
        }
        .buttonStyle(.plain)
    }
    
    var dotColor: Color {
        if completionPercentage >= 1.0 {
            return AppColors.green
        } else if completionPercentage > 0 {
            return AppColors.green.opacity(0.6)
        } else {
            return AppColors.lightGray
        }
    }
}

// MARK: - Legend Item
struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textMuted)
        }
    }
}

#Preview {
    CalendarView()
        .environment(AppViewModel())
}
