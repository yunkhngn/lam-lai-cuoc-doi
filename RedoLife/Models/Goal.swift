import Foundation
import SwiftData

@Model
final class Goal {
    var id: UUID
    var name: String
    var icon: String
    var isCompleted: Bool
    var completedDate: Date?
    var deadline: Date?
    var isLongTerm: Bool
    var createdAt: Date
    var order: Int
    
    init(
        name: String,
        icon: String = "star.fill",
        deadline: Date? = nil,
        isLongTerm: Bool = false,
        order: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.isCompleted = false
        self.completedDate = nil
        self.deadline = deadline
        self.isLongTerm = isLongTerm
        self.createdAt = Date()
        self.order = order
    }
}
