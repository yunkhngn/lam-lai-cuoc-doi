import Foundation
import SwiftData

@Model
final class Routine {
    var id: UUID
    var name: String
    var icon: String
    var isActive: Bool
    var order: Int
    var createdAt: Date
    var archivedAt: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \DailyLog.routine)
    var dailyLogs: [DailyLog]?
    
    init(name: String, icon: String = "star.fill", isActive: Bool = true, order: Int = 0) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.isActive = isActive
        self.order = order
        self.createdAt = Date()
        self.archivedAt = nil
    }
}
