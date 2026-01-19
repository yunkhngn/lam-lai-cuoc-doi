import Foundation
import SwiftData

@Model
final class PlayerStats {
    var totalXP: Int
    var currentStreak: Int
    var bestStreak: Int
    var level: Int
    var lastActiveDate: Date?
    
    init(totalXP: Int = 0, currentStreak: Int = 0, bestStreak: Int = 0, level: Int = 1) {
        self.totalXP = totalXP
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.level = level
        self.lastActiveDate = Date()
    }
}
