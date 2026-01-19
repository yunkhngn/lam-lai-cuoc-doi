import Foundation
import SwiftData

@Model
final class DailyLog {
    var id: UUID
    var date: Date // Should be normalized to midnight of the day
    var isDone: Bool
    
    var routine: Routine?
    
    init(date: Date, isDone: Bool = false, routine: Routine? = nil) {
        self.id = UUID()
        self.date = date
        self.isDone = isDone
        self.routine = routine
    }
}
