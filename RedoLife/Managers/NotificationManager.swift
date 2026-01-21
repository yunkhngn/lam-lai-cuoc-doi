import Foundation
import UserNotifications

// Quotes for hourly notifications - same as DashboardView
let motivationalQuotes: [String] = [
    "Hôm nay cậu vẫn còn đứng dậy là vẫn có thể bước tiếp.",
    "Không cần tốt hơn ai cả. Chỉ cần cậu không bỏ cuộc.",
    "Nếu cậu thấy mệt, chậm lại chút cũng được.",
    "Mọi việc nhỏ hôm nay đều có ý nghĩa lớn.",
    "Không sao cả nếu hôm nay của cậu không ổn.",
    "Chỉ cần cố thêm chút thôi. Cố gắng lên nhé!",
    "Cậu đang không lạc hướng. Hãy cố gắng nhé!",
    "Hôm nay cậu chưa ổn không có nghĩa là mai cũng vậy."
]

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override init() {
        super.init()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
                self.scheduleDailyReminders()
            } else if let error = error {
                print("Notification permission denied: \(error)")
            }
        }
    }
    
    func scheduleDailyReminders() {
        let morningHour = UserDefaults.standard.integer(forKey: "morningReminderHour")
        let eveningHour = UserDefaults.standard.integer(forKey: "eveningReminderHour")
        let quoteInterval = UserDefaults.standard.integer(forKey: "quoteIntervalHours")
        
        scheduleReminders(
            morningHour: morningHour == 0 ? 9 : morningHour,
            eveningHour: eveningHour == 0 ? 21 : eveningHour,
            quoteInterval: quoteInterval == 0 ? 1 : quoteInterval
        )
    }
    
    func scheduleReminders(morningHour: Int, eveningHour: Int, quoteInterval: Int) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // 1. Gentle Morning
        scheduleNotification(
            identifier: "daily_reminder",
            title: "Chào buổi sáng ☀️",
            body: "Sẵn sàng cho một ngày ý nghĩa chưa?",
            hour: morningHour,
            minute: 0
        )
        
        // 2. End of Day Recap
        scheduleNotification(
            identifier: "evening_recap",
            title: "Tổng kết cuối ngày 🌙",
            body: "Dành chút thời gian nhìn lại ngày hôm nay nhé.",
            hour: eveningHour,
            minute: 0
        )
        
        // 3. Motivational quotes
        scheduleHourlyQuotes(interval: quoteInterval)
        
        // 4. Low Progress Checks (Default ON, cancelled dynamically)
        scheduleLowProgressReminders()
        
        // 5. Streak Saver (Default ON, cancelled if progress > 0)
        scheduleStreakSaver()
    }
    
    func scheduleHourlyQuotes(interval: Int) {
        // Schedule from 10 AM to 8 PM
        let startHour = 10
        let endHour = 20 // Inclusive
        
        // Use stride to jump by interval
        for hour in stride(from: startHour, through: endHour, by: interval) {
            let quoteIndex = hour % motivationalQuotes.count
            let quote = motivationalQuotes[quoteIndex]
            
            scheduleNotification(
                identifier: "quote_\(hour)",
                title: "💭 Một chút động lực",
                body: quote,
                hour: hour,
                minute: 0
            )
        }
    }
    
    // MARK: - Conditional Progress Reminders
    
    func scheduleLowProgressReminders() {
        // Checkpoints: 9h, 12h, 15h, 18h, 21h
        let checkpoints = [9, 12, 15, 18, 21]
        
        for hour in checkpoints {
            scheduleNotification(
                identifier: "low_progress_\(hour)",
                title: "🔔 Nhắc nhở tiến độ",
                body: "Bạn chưa hoàn thành 30% mục tiêu hôm nay. Cố lên nhé! 💪",
                hour: hour,
                minute: 0
            )
        }
    }
    
    // MARK: - Streak Saver
    
    func scheduleStreakSaver() {
        // Schedule for 22:00 (10 PM)
        scheduleNotification(
            identifier: "streak_saver",
            title: "🔥 Đừng để mất chuỗi!",
            body: "Bạn sắp mất chuỗi hoàn thành. Hãy vào app và hoàn thành nốt thói quen ngay!",
            hour: 22,
            minute: 0
        )
    }
    
    func cancelStreakSaver() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["streak_saver"])
    }
    
    // MARK: - Conditional Progress Reminders
        let center = UNUserNotificationCenter.current()
        let checkpoints = [9, 12, 15, 18, 21]
        let identifiers = checkpoints.map { "low_progress_\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        // print("Cancelled low progress reminders")
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func scheduleNotification(identifier: String, title: String, body: String, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Delegate to handle notifications while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

