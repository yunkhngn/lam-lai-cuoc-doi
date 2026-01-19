import Foundation
import SwiftData

@Model
final class PlayerStats {
    var totalXP: Int
    var currentStreak: Int
    var bestStreak: Int
    var level: Int
    var lastActiveDate: Date?
    var todayXP: Int  // Track today's XP for proper recalculation
    
    init(totalXP: Int = 0, currentStreak: Int = 0, bestStreak: Int = 0, level: Int = 1) {
        self.totalXP = totalXP
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.level = level
        self.lastActiveDate = Date()
        self.todayXP = 0
    }
}
