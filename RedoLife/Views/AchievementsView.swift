import SwiftUI
import SwiftData

// MARK: - Achievement Manager

class AchievementManager {
    static let shared = AchievementManager()
    
    func checkUnlock(type: AchievementType, context: ModelContext, stats: PlayerStats) -> Bool {
        // Check if already unlocked
        let descriptor = FetchDescriptor<UserAchievement>(
            predicate: #Predicate { $0.typeRaw == type.rawValue }
        )
        
        do {
            let existing = try context.fetch(descriptor)
            if !existing.isEmpty { return false } // Already unlocked
            
            // Should unlock?
            if shouldUnlock(type: type, stats: stats) {
                let newAchievement = UserAchievement(type: type)
                context.insert(newAchievement)
                return true
            }
        } catch {
            print("Error checking achievement: \(error)")
        }
        
        return false
    }
    
    private func shouldUnlock(type: AchievementType, stats: PlayerStats) -> Bool {
        switch type {
        case .onFire:
            return stats.currentStreak >= 7 // Match the description/icon requirement
        case .earlyBird:
            // Proxy: User has accumulated some XP (Active user)
            // Real implementation requires tracking completion time
            return stats.totalXP >= 100
        case .weekendWarrior:
            // Proxy: User has accumulated significant XP (Long term user)
            // Real implementation requires calendar analysis
            return stats.totalXP >= 1000
        }
    }
}

// MARK: - Achievements View

struct AchievementsView: View {
    @Environment(AppViewModel.self) var viewModel
    @Query var unlockedAchievements: [UserAchievement]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Bộ sưu tập")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.top, 40)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                    ForEach(AchievementType.allCases, id: \.self) { type in
                        let isUnlocked = unlockedAchievements.contains { $0.type == type }
                        AchievementBadge(type: type, isUnlocked: isUnlocked)
                    }
                }
            }
            .padding(24)
        }
        .background(AppColors.bgPrimary)
    }
}

struct AchievementBadge: View {
    let type: AchievementType
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? AppColors.green.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: type.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(isUnlocked ? AppColors.green : Color.gray)
                    .symbolEffect(.bounce, value: isUnlocked)
            }
            .saturation(isUnlocked ? 1.0 : 0.0)
            
            VStack(spacing: 4) {
                Text(type.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isUnlocked ? AppColors.textPrimary : .gray)
                
                Text(type.description)
                    .font(.system(size: 11))
                    .foregroundStyle(isUnlocked ? AppColors.textMuted : .gray.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}
