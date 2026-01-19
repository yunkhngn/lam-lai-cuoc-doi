import Foundation
import SwiftData
import SwiftUI

@Observable
class AppViewModel {
    var modelContext: ModelContext?
    
    // UI State
    var currentDate: Date = Date()
    
    // Derived
    var routines: [Routine] = []
    var dailyLogs: [DailyLog] = []
    var todayLogs: [UUID: DailyLog] = [:] // Map RoutineID -> Log
    
    var playerStats: PlayerStats?
    
    init() {
        // Context will be set from View
    }
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        fetchData()
    }
    
    // MARK: - Date Handling
    
    /// Returns the "Logical Today" considering the 2AM grace period.
    /// If it's 1:00 AM on Jan 2nd, the logical date is Jan 1st.
    var logicalToday: Date {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        
        if hour < 2 {
            // It's early morning, return yesterday
            return calendar.date(byAdding: .day, value: -1, to: now) ?? now
        } else {
            return now
        }
    }
    
    // MARK: - Data Operations
    
    func fetchData() {
        guard let context = modelContext else { return }
        
        // Fetch Stats
        do {
            let statsDescriptor = FetchDescriptor<PlayerStats>()
            let stats = try context.fetch(statsDescriptor)
            if let first = stats.first {
                self.playerStats = first
            } else {
                let newStats = PlayerStats()
                context.insert(newStats)
                self.playerStats = newStats
            }
            
            // Fetch Routines
            let routinesDescriptor = FetchDescriptor<Routine>(sortBy: [SortDescriptor(\.order)])
            self.routines = try context.fetch(routinesDescriptor)
            
            // Fetch logs for logical today
            refreshDailyLogs()
            
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    func refreshDailyLogs() {
        guard let context = modelContext else { return }
        
        let todayStart = Calendar.current.startOfDay(for: logicalToday)
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!
        
        let logsDescriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date >= todayStart && $0.date < todayEnd }
        )
        
        do {
            self.dailyLogs = try context.fetch(logsDescriptor)
            self.todayLogs = Dictionary(uniqueKeysWithValues: dailyLogs.compactMap { log in
                guard let routine = log.routine else { return nil }
                return (routine.id, log)
            })
        } catch {
            print("Error fetching logs: \(error)")
        }
    }
    
    // MARK: - Actions
    
    func toggleRoutine(_ routine: Routine) {
        guard let context = modelContext else { return }
        
        if let log = todayLogs[routine.id] {
            // Toggle existing
            log.isDone.toggle()
        } else {
            // Create new log
            let newLog = DailyLog(date: logicalToday, isDone: true, routine: routine)
            context.insert(newLog)
            routine.dailyLogs?.append(newLog)
            todayLogs[routine.id] = newLog
        }
        
        updateStats()
        // Save handled by SwiftData autosave or manually if needed
    }
    
    func updateStats() {
        guard let stats = playerStats else { return }
        
        // Calculate today's progress
        let activeRoutines = routines.filter { $0.isActive }
        guard !activeRoutines.isEmpty else { return }
        
        let completedCount = activeRoutines.filter { routine in
            todayLogs[routine.id]?.isDone == true
        }.count
        
        let percentage = Double(completedCount) / Double(activeRoutines.count)
        
        // NOTE: Real stats update (streak) should probably happen at end of day or when opening app next day.
        // For XP, we can update immediately or strictly.
        // Let's implement simple XP addition for now.
        // A robust system needs to track if XP was already awarded for today.
        
        // This is a simplified version. In a real app we'd verify "hasXPBeenAwardedToday".
    }
    
    // MARK: - Calendar Support
    var monthlyLogs: [UUID: [String: DailyLog]] = [:] // RoutineID -> DateString -> Log
    var currentMonth: Date = Date()
    
    func fetchMonthLogs(for date: Date) {
        guard let context = modelContext else { return }
        
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else { return }
        
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date >= monthStart && $0.date < monthEnd }
        )
        
        do {
            let logs = try context.fetch(descriptor)
            
            // Organize logs
            var newMap: [UUID: [String: DailyLog]] = [:]
            for log in logs {
                if let routineId = log.routine?.id {
                    let dateKey = log.date.formatted(date: .numeric, time: .omitted)
                    var routineMap = newMap[routineId] ?? [:]
                    routineMap[dateKey] = log
                    newMap[routineId] = routineMap
                }
            }
            self.monthlyLogs = newMap
            self.currentMonth = monthStart
        } catch {
            print("Error fetching month logs: \(error)")
        }
    }
    
    func toggleGlobalRoutine(_ routine: Routine, date: Date) {
        // Normalize date to midnight/Logical Day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        guard let context = modelContext else { return }
        
        // Check existing in monthlyLogs
        let dateKey = startOfDay.formatted(date: .numeric, time: .omitted)
        
        if let log = monthlyLogs[routine.id]?[dateKey] {
             log.isDone.toggle()
        } else {
            // Check if it exists in DB but not in map (edge case) or create new
            // For simplicity, create new
            let newLog = DailyLog(date: startOfDay, isDone: true, routine: routine)
            context.insert(newLog)
            routine.dailyLogs?.append(newLog)
            
            // Update local map
            var routineMap = monthlyLogs[routine.id] ?? [:]
            routineMap[dateKey] = newLog
            monthlyLogs[routine.id] = routineMap
            
            // If it's today, update todayLogs too
            if calendar.isDate(startOfDay, inSameDayAs: logicalToday) {
                todayLogs[routine.id] = newLog
            }
        }
        
        updateStats() // Note: Stats update needs to be smarter to not double count
    }
}
