import Foundation
import SwiftData
import SwiftUI

// MARK: - Mood Tracker Models

enum Mood: String, Codable, CaseIterable {
    case happy = "happy"
    case neutral = "neutral"
    case sad = "sad"
    case tired = "tired"
    
    var icon: String {
        switch self {
        case .happy: return "😆"
        case .neutral: return "😐"
        case .sad: return "😔"
        case .tired: return "😫"
        }
    }
    
    var label: String {
        switch self {
        case .happy: return "Vui"
        case .neutral: return "Bình thường"
        case .sad: return "Buồn"
        case .tired: return "Mệt mỏi"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return Color.green
        case .neutral: return Color.blue
        case .sad: return Color.indigo
        case .tired: return Color.gray
        }
    }
}

@Model
class MoodLog {
    var id: UUID
    var date: Date
    var moodRaw: String
    var note: String
    
    var mood: Mood {
        get { Mood(rawValue: moodRaw) ?? .neutral }
        set { moodRaw = newValue.rawValue }
    }
    
    init(date: Date = Date(), mood: Mood, note: String = "") {
        self.id = UUID()
        self.date = date
        self.moodRaw = mood.rawValue
        self.note = note
    }
}

// MARK: - Focus Timer Models
// (Simple state, maybe persistent history later if needed)

// MARK: - Achievements Models

enum AchievementType: String, Codable, CaseIterable {
    case earlyBird = "earlyBird"
    case onFire = "onFire"
    case weekendWarrior = "weekendWarrior"

    
    var title: String {
        switch self {
        case .earlyBird: return "Early Bird"
        case .onFire: return "On Fire"
        case .weekendWarrior: return "Weekend Warrior"

        }
    }
    
    var description: String {
        switch self {
        case .earlyBird: return "Hoàn thành thói quen trước 7h sáng (3 ngày)"
        case .onFire: return "Duy trì chuỗi 7 ngày liên tiếp"
        case .weekendWarrior: return "Không bỏ ngày cuối tuần nào trong tháng"

        }
    }
    
    var icon: String {
        switch self {
        case .earlyBird: return "sunrise.fill"
        case .onFire: return "flame.fill"
        case .weekendWarrior: return "shield.fill"

        }
    }
}

@Model
class UserAchievement {
    var id: UUID
    var typeRaw: String
    var unlockedDate: Date
    
    var type: AchievementType {
        get { AchievementType(rawValue: typeRaw) ?? .earlyBird }
        set { typeRaw = newValue.rawValue }
    }
    
    init(type: AchievementType, unlockedDate: Date = Date()) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.unlockedDate = unlockedDate
    }
}
