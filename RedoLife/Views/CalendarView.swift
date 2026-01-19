import SwiftUI

struct CalendarView: View {
    @Environment(AppViewModel.self) var viewModel
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text(viewModel.currentMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                
                HStack {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    Button("Today") {
                        viewModel.fetchMonthLogs(for: Date())
                    }
                }
            }
            .padding()
            
            // Grid
            ScrollView([.horizontal, .vertical]) {
                Grid(alignment: .center, horizontalSpacing: 1, verticalSpacing: 1) {
                    // Header Row (Days)
                    GridRow {
                        Color.clear.gridCellColumns(1) // Spacer for routine name
                        ForEach(daysInMonth(), id: \.self) { date in
                            VStack(spacing: 4) {
                                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(date.formatted(.dateTime.day()))
                                    .font(.caption)
                                    .fontWeight(Calendar.current.isDateInToday(date) ? .bold : .regular)
                                    .foregroundStyle(Calendar.current.isDateInToday(date) ? .blue : .primary)
                            }
                            .frame(width: 32)
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Divider()
                    
                    // Routine Rows
                    ForEach(viewModel.routines.filter { $0.isActive }) { routine in
                        GridRow {
                            // Routine Name
                            HStack {
                                Image(systemName: routine.icon)
                                Text(routine.name)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .frame(width: 150)
                            .padding(.horizontal)
                            
                            // Days
                            ForEach(daysInMonth(), id: \.self) { date in
                                let dateKey = date.formatted(date: .numeric, time: .omitted)
                                let isDone = viewModel.monthlyLogs[routine.id]?[dateKey]?.isDone ?? false
                                
                                Button {
                                    withAnimation {
                                        viewModel.toggleGlobalRoutine(routine, date: date)
                                    }
                                } label: {
                                    ZStack {
                                        if isDone {
                                            Circle()
                                                .fill(Color.green.opacity(0.8))
                                                .frame(width: 20, height: 20)
                                            Image(systemName: "checkmark")
                                                .font(.caption2)
                                                .foregroundStyle(.white)
                                        } else {
                                            Circle()
                                                .fill(Color.secondary.opacity(0.1))
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    .frame(width: 32, height: 32)
                                    .contentShape(Rectangle()) // Hit test
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        Divider()
                    }
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.fetchMonthLogs(for: Date())
        }
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
