import Foundation
import UserNotifications

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
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // 1. Gentle Morning specific time (e.g. 9 AM)
        scheduleNotification(
            identifier: "daily_reminder",
            title: "Chào buổi sáng",
            body: "Sẵn sàng cho một ngày ý nghĩa chưa?",
            hour: 9,
            minute: 0
        )
        
        // 2. End of Day Recap (e.g. 9 PM)
        scheduleNotification(
            identifier: "evening_recap",
            title: "Tổng kết cuối ngày",
            body: "Dành chút thời gian nhìn lại ngày hôm nay nhé.",
            hour: 21,
            minute: 0
        )
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
