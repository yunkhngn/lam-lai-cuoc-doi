import Foundation

class GamificationEngine {
    static let shared = GamificationEngine()
    
    // Constants
    let xpPerTask = 10
    let xpBonusAllTasks = 20
    
    // Streak Rules
    func calculateNewStreak(currentStreak: Int, completionPercentage: Double) -> Int {
        if completionPercentage >= 1.0 {
            return currentStreak + 1
        } else if completionPercentage >= 0.7 {
            return currentStreak // Maintain streak
        } else {
            return max(0, currentStreak - 1) // Decay streak, don't reset to 0 immediately
        }
    }
    
    func calculateXP(completedCount: Int, totalCount: Int) -> Int {
        var xp = completedCount * xpPerTask
        if totalCount > 0 && completedCount == totalCount {
            xp += xpBonusAllTasks
        }
        return xp
    }
}
