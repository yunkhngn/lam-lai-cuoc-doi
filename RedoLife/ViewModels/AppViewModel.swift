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
    
    // Goals
    var goals: [Goal] = []
    
    var goalsProgress: Double {
        guard !goals.isEmpty else { return 0 }
        let completed = goals.filter { $0.isCompleted }.count
        return Double(completed) / Double(goals.count)
    }
    
    var playerStats: PlayerStats?
    
    // Mood

    
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
            
            // Fetch Goals
            let goalsDescriptor = FetchDescriptor<Goal>(sortBy: [SortDescriptor(\.order)])
            self.goals = try context.fetch(goalsDescriptor)
            
            // Migration: Fix legacy archived routines
            // If inactive and archivedAt is nil, set it to now so they show up in history
            let legacyArchived = self.routines.filter { !$0.isActive && $0.archivedAt == nil }
            if !legacyArchived.isEmpty {
                for routine in legacyArchived {
                    routine.archivedAt = Date()
                }
                // Save context will happen on next run logic or implicit
            }
            
            // Fetch logs for logical today
            refreshDailyLogs()
            

            
            // Make sure Chart Data is up to date
            fetchLast7DaysLogs()
            
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
            
            // Build dictionary manually to handle duplicates (last one wins)
            var logsMap: [UUID: DailyLog] = [:]
            for log in dailyLogs {
                guard let routine = log.routine else { continue }
                logsMap[routine.id] = log // Overwrites if duplicate
            }
            self.todayLogs = logsMap
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
        
        lastUpdate = Date()
        updateStats()
        // Save handled by SwiftData autosave or manually if needed
    }
    
    // Signals for UI updates
    var lastUpdate: Date = Date()
    
    // MARK: - Goal Actions
    
    func toggleGoal(_ goal: Goal) {
        goal.isCompleted.toggle()
        if goal.isCompleted {
            goal.completedDate = Date()
        } else {
            goal.completedDate = nil
        }
        lastUpdate = Date()
    }
    
    func deleteGoal(_ goal: Goal) {
        guard let context = modelContext else { return }
        context.delete(goal)
        fetchData() // this will update goals list
    }
    
    func updateGoal(_ goal: Goal, name: String, deadline: Date?, isLongTerm: Bool) {
        goal.name = name
        goal.deadline = deadline
        goal.isLongTerm = isLongTerm
        lastUpdate = Date()
    }
    
    func moveRoutine(from source: IndexSet, to destination: Int) {
        var activeRoutines = routines.filter { $0.isActive }.sorted { $0.order < $1.order }
        activeRoutines.move(fromOffsets: source, toOffset: destination)
        
        // Re-assign order based on new position
        for (index, routine) in activeRoutines.enumerated() {
            routine.order = index
        }
        
        // Save Context implicitly handled or triggers fetch if needed
        // Ideally we update the main `routines` array too or just re-fetch
        fetchData()
    }
    
    func moveGoal(from source: IndexSet, to destination: Int) {
        // Similar logic for goals if needed
        var activeGoals = goals.filter { $0.isActive }.sorted { $0.order < $1.order }
        activeGoals.move(fromOffsets: source, toOffset: destination)
        
        for (index, goal) in activeGoals.enumerated() {
            goal.order = index
        }
        fetchData()
    }
    
    func updateStats() {
        guard let stats = playerStats else { return }
        lastUpdate = Date()
        
        // Calculate today's progress
        let activeRoutines = routines.filter { $0.isActive }
        guard !activeRoutines.isEmpty else { return }
        
        let completedCount = activeRoutines.filter { routine in
            todayLogs[routine.id]?.isDone == true
        }.count
        
        let percentage = Double(completedCount) / Double(activeRoutines.count)
        
        // Today's XP: percentage * 1204
        let newTodayXP = Int(percentage * 1204)
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: logicalToday)
        
        // Check if we already have a record for today
        if let lastActive = stats.lastActiveDate {
            let lastActiveDay = calendar.startOfDay(for: lastActive)
            let isSameDay = calendar.isDate(lastActiveDay, inSameDayAs: today)
            
            if isSameDay {
                // Same day - recalculate XP using persisted todayXP
                let baseXP = stats.totalXP - stats.todayXP
                stats.totalXP = baseXP + newTodayXP
                stats.todayXP = newTodayXP
            } else {
                // New day - reset todayXP
                stats.todayXP = 0
                
                let daysDiff = calendar.dateComponents([.day], from: lastActiveDay, to: today).day ?? 0
                
                if daysDiff == 1 {
                    // Consecutive day
                    stats.currentStreak += 1
                } else {
                    // Streak broken - reset
                    stats.currentStreak = 1
                }
                
                // Add today's XP
                stats.totalXP += newTodayXP
                stats.todayXP = newTodayXP
                stats.lastActiveDate = today
            }
        } else {
            // First time ever
            stats.currentStreak = 1
            stats.totalXP = newTodayXP
            stats.todayXP = newTodayXP
            stats.lastActiveDate = today
        }
        
        // Update best streak
        if stats.currentStreak > stats.bestStreak {
            stats.bestStreak = stats.currentStreak
        }
        
        // Calculate level (every 100 XP = 1 level)
        stats.level = stats.totalXP / 100
        
        // Check Notification Condition (Low Progress Reminder)
        checkProgressReminders(percentage: percentage)
        
        // Check Achievements
        if let context = modelContext {
            // Check On Fire (Streak)
            _ = AchievementManager.shared.checkUnlock(type: .onFire, context: context, stats: stats)
            
            // Check Early Bird/Weekend Warrior would require more complex log analysis
            // For simplicity, let's just trigger streak check here
        }
    }
    
    func checkProgressReminders(percentage: Double) {
        if percentage >= 0.3 {
            // Good progress -> Cancel annoying reminders
            NotificationManager.shared.cancelLowProgressReminders()
        } else {
            // Low progress -> Ensure reminders are active
            // Note: This might be redundant if already scheduled, but safe to ensuring consistency
            // However, we avoid spamming re-schedule on every toggle if < 30%.
            // Strategy: We rely on "Cancellation" being the main action. 
            // Re-scheduling only happens on App Launch or if we want strict enforcement.
            // For now, let's keep it simple: Cancel if >= 30%.
            // If user unchecks items and drops below 30%, we could re-enable.
            NotificationManager.shared.scheduleLowProgressReminders()
        }
    }
    
    // MARK: - Calendar Support
    var monthlyLogs: [UUID: [String: DailyLog]] = [:] // RoutineID -> DateString -> Log
    var currentMonth: Date = Date()
    
    // MARK: - Stats Support
    var last7DaysLogs: [UUID: [String: DailyLog]] = [:] // For StatsView
    var last90DaysLogs: [Date: [DailyLog]] = [:] // Map Date -> Logs for that day
    var routineStats: [UUID: (name: String, icon: String, completionCount: Int)] = [:]

    
    func fetchActivityData() {
        guard let context = modelContext else { return }
        
        // 1. Fetch 365 Days Logs for Heatmap (1 Year)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -364, to: today) else { return }
        
        // ... (Heatmap logic unchanged implies rest of function remains, but I need to be careful with replace)
        // I will replace fetchActivityData and helpers to be safe and clean.
        
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date >= startDate }
        )
        
        do {
            let logs = try context.fetch(descriptor)
            
            // Organize for Heatmap: Date -> [Logs]
            var map: [Date: [DailyLog]] = [:]
            var rStats: [UUID: Int] = [:]
            
            for log in logs {
                if log.isDone {
                    let dateKey = calendar.startOfDay(for: log.date)
                    map[dateKey, default: []].append(log)
                    
                    if let rId = log.routine?.id {
                        rStats[rId, default: 0] += 1
                    }
                }
            }
            self.last90DaysLogs = map
            
            // 2. Prepare Routine Stats
            var finalStats: [UUID: (name: String, icon: String, completionCount: Int)] = [:]
            for routine in routines {
                finalStats[routine.id] = (routine.name, routine.icon, rStats[routine.id] ?? 0)
            }
            self.routineStats = finalStats
            
            // 3. Update 7 days logs
            fetchLast7DaysLogs()
            
        } catch {
            print("Error fetching activity data: \(error)")
        }
    }
    
    func fetchLast7DaysLogs() {
        guard let context = modelContext else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: today),
              let endDate = calendar.date(byAdding: .day, value: 1, to: today) else { return }
        
        // Routines Logs
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date >= startDate && $0.date < endDate }
        )
        
        do {
            let logs = try context.fetch(descriptor)
            var newMap: [UUID: [String: DailyLog]] = [:]
            for log in logs {
                if let routineId = log.routine?.id {
                    let dateKey = calendar.startOfDay(for: log.date).formatted(date: .numeric, time: .omitted)
                    var routineMap = newMap[routineId] ?? [:]
                    routineMap[dateKey] = log
                    newMap[routineId] = routineMap
                }
            }
            self.last7DaysLogs = newMap
            

            
        } catch {
            print("Error fetching 7 days logs: \(error)")
        }
    }
    
    // ... (fetchMonthLogs matches original line 359)
    
    // ... (toggleGlobalRoutine matches original line 390)
    
    // MARK: - Mood Logic
    

    

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
    

    

    

    // MARK: - Dev Tools
    // MARK: - Safe Dev Tools
    func exportData() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        // Map database models to DTOs
        let routineDTOs = routines.map { routine in
            RoutineBackup(
                id: routine.id,
                name: routine.name,
                icon: routine.icon,
                isActive: routine.isActive,
                order: routine.order,
                createdAt: routine.createdAt,
                archivedAt: routine.archivedAt
            )
        }
        
        let goalDTOs = goals.map { goal in
            GoalBackup(
                id: goal.id,
                name: goal.name,
                icon: goal.icon,
                isCompleted: goal.isCompleted,
                completedDate: goal.completedDate,
                deadline: goal.deadline,
                isLongTerm: goal.isLongTerm,
                createdAt: goal.createdAt,
                order: goal.order,
                isActive: goal.isActive,
                archivedAt: goal.archivedAt
            )
        }
        
        do {
            let backup = BackupData(routines: routineDTOs, goals: goalDTOs)
            let data = try encoder.encode(backup)
            
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("redo_life_backup.json")
            try data.write(to: url)
            print("Backup saved to: \(url.path)")
        } catch {
            print("Backup failed: \(error)")
        }
    }
    
    struct BackupData: Codable {
        let routines: [RoutineBackup]
        let goals: [GoalBackup]
    }
    
    struct RoutineBackup: Codable {
        let id: UUID
        let name: String
        let icon: String
        let isActive: Bool
        let order: Int
        let createdAt: Date
        let archivedAt: Date?
    }
    
    struct GoalBackup: Codable {
        let id: UUID
        let name: String
        let icon: String
        let isCompleted: Bool
        let completedDate: Date?
        let deadline: Date?
        let isLongTerm: Bool
        let createdAt: Date
        let order: Int
        let isActive: Bool
        let archivedAt: Date?
    }
    
    // Helper to delete injected data (Prevent mixing dev data with real data permanently)
    func deleteSampleData() {
        guard let context = modelContext else { return }
        
        let sampleRoutineNames = ["Dậy sớm", "Đọc sách", "Chạy bộ", "Code dạo", "Uống nước", "Thiền"]
        let sampleGoalNames = ["Đọc 10 cuốn sách", "Tiết kiệm 100tr", "Học AI Agent", "Đi Đà Lạt"]
        
        for routine in routines {
            if sampleRoutineNames.contains(routine.name) {
                context.delete(routine)
            }
        }
        
        for goal in goals {
            if sampleGoalNames.contains(goal.name) {
                context.delete(goal)
            }
        }
        
        fetchData()
        print("Sample data deleted!")
    }
    func injectSampleData() {
        guard let context = modelContext else { return }
        
        // Safety: Try to clean previous sample data first to avoid duplicates
        deleteSampleData() 
        // Note: deleteSampleData calls fetchData, but we continue...
        
        // 1. Create Sample Routines
        let routineNames = [
            ("Dậy sớm", "sun.max.fill"),
            ("Đọc sách", "book.fill"),
            ("Chạy bộ", "figure.run"),
            ("Code dạo", "laptopcomputer"),
            ("Uống nước", "drop.fill"),
            ("Thiền", "wind")
        ]
        
        var createdRoutines: [Routine] = []
        
        for (index, (name, icon)) in routineNames.enumerated() {
            let routine = Routine(name: name, icon: icon, order: index)
            context.insert(routine)
            createdRoutines.append(routine)
        }
        
        // 2. Create Sample Logs (Past 90 days)
        // CRITICAL: We must fetch ALL routines (including user's existing ones) to ensure 100% completion
        let routinesDescriptor = FetchDescriptor<Routine>()
        let allRoutines = (try? context.fetch(routinesDescriptor)) ?? createdRoutines
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // FIRST: Delete all existing logs for the last 7 days to prevent duplicates
        if let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today) {
            let logsToDeleteDescriptor = FetchDescriptor<DailyLog>(
                predicate: #Predicate { $0.date >= sevenDaysAgo }
            )
            if let existingLogs = try? context.fetch(logsToDeleteDescriptor) {
                for log in existingLogs {
                    context.delete(log)
                }
            }
        }
        
        for i in 0..<90 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            // Force perfect streak for the last 7 days (including today)
            // We must complete EVERY active routine to get 100%
            if i < 7 {
                for routine in allRoutines {
                    // Only log if routine was created before or on this date (simplified: just do it)
                    // We assume active routines should be done.
                    if routine.isActive {
                        let log = DailyLog(date: date, isDone: true, routine: routine)
                        context.insert(log)
                    }
                }
            } else {
                // Random history for sample routines only (to avoid messing up user's history too much)
                for routine in createdRoutines {
                    if Bool.random() { // 50% chance
                        let isDone = Double.random(in: 0...1) > 0.3
                        if isDone {
                            let log = DailyLog(date: date, isDone: true, routine: routine)
                            context.insert(log)
                        }
                    }
                }
            }
        }
        
        // 3. Create Sample Goals
        let goalNames = [
            ("Đọc 10 cuốn sách", true),
            ("Tiết kiệm 100tr", true),
            ("Học AI Agent", false),
            ("Đi Đà Lạt", false)
        ]
        
        for (index, (name, isLongTerm)) in goalNames.enumerated() {
            let goal = Goal(name: name, isLongTerm: isLongTerm, order: index)
            if index % 2 == 0 { // Make some completed
                goal.isCompleted = true
                goal.completedDate = Date().addingTimeInterval(-86400 * Double(index))
            }
            context.insert(goal)
        }
        
        // 4. Update Stats and Logs
        try? context.save() // Ensure save before fetch
        fetchData()
        fetchActivityData()
        fetchMonthLogs(for: currentMonth) // CRITICAL: Refresh Calendar
        
        // 5. Force update PlayerStats and Check Achievements
        if let stats = self.playerStats {
            stats.currentStreak = 7 // Force streak to match injected data
            stats.todayXP = 1200 // Arbitrary XP for visual
            
            // Trigger achievement check
            _ = AchievementManager.shared.checkUnlock(type: .onFire, context: context, stats: stats)
            // Also check Early Bird if applicable (not fully implemented logic yet but good to trigger)
            _ = AchievementManager.shared.checkUnlock(type: .earlyBird, context: context, stats: stats)
             _ = AchievementManager.shared.checkUnlock(type: .weekendWarrior, context: context, stats: stats)
        }
        
        print("Sample data injected & Stats updated!")
    }
}
