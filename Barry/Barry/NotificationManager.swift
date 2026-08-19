import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// weekday = 1...7, Sunday = 1, Saturday = 7 (Calendar/DateComponents convention)
    func reschedule(settings: AppSettings) {
        let center = UNUserNotificationCenter.current()
        let ids = (1...7).flatMap { ["barry-\($0)"] }
        center.removePendingNotificationRequests(withIdentifiers: ids)

        let content = UNMutableNotificationContent()
        content.title = "Barry Co."
        content.body = "Go see what today's assignment is."
        content.sound = .default

        for weekday in 1...7 {
            let isWeekend = (weekday == 1 || weekday == 7)  // Sun or Sat
            var dc = DateComponents()
            dc.weekday = weekday
            dc.hour = isWeekend ? settings.weekendHour : settings.weekdayHour
            dc.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            let request = UNNotificationRequest(identifier: "barry-\(weekday)", content: content, trigger: trigger)
            center.add(request)
        }
    }
}
