//
//  NotificationsManager.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/8/25.
//

import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    enum NotificationStatus {
        case notDetermined
        case denied
        case authorized
        case provisional
    }
    
    func checkNotificationStatus(completion: @escaping (NotificationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    completion(.notDetermined)
                case .denied:
                    completion(.denied)
                case .authorized:
                    completion(.authorized)
                case .provisional:
                    completion(.provisional)
                default:
                    completion(.denied)
                }
            }
        }
    }
    
    func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        checkNotificationStatus { status in
            switch status {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in // swiftlint:disable:this line_length
                    completion(granted)
                }
            case .authorized, .provisional:
                completion(true)
            case .denied:
                completion(false)
            }
        }
    }
    
    func scheduleAllNotifications() {
        if CloudSettings.shared.enableNotifications {
            scheduleDailyCalorieReminders()
            scheduleWeeklyMeasurementReminders()
        }
    }
    
    func cancelTodaysCalorieReminder() {
        let calendar = Calendar.current
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        let identifier = "sculpty-daily-calorie-reminder-\(today.year!)-\(today.month!)-\(today.day!)" // swiftlint:disable:this line_length force_unwrapping
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func enableNotifications() {
        scheduleAllNotifications()
    }
    
    func disableNotifications() {
        cancelAllNotifications()
    }
    
    func enableCaloriesNotifications() {
        scheduleDailyCalorieReminders()
    }
    
    func disableCaloriesNotifications() {
        cancelAllNotifications()
        scheduleWeeklyMeasurementReminders()
    }
    
    func enableMeasurementsNotifications() {
        scheduleWeeklyMeasurementReminders()
    }
    
    func disableMeasurementsNotifications() {
        cancelAllNotifications()
        scheduleDailyCalorieReminders()
    }
    
    private func scheduleWeeklyMeasurementReminders() {
        if CloudSettings.shared.enableMeasurementsNotifications {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            let content = UNMutableNotificationContent()
            content.title = "Progress Check!"
            content.body = "See how far you've come - record your measurements 💪"
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.weekday = 1
            /*
             1 = Sunday
             2 = Monday
             3 = Tuesday
             4 = Wednesday
             5 = Thursday
             6 = Friday
             7 = Saturday
             */
            dateComponents.hour = 9
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "sculpty-weekly-measurement",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    private func scheduleDailyCalorieReminders() {
        if CloudSettings.shared.enableCaloriesNotifications {
            let calendar = Calendar.current
            
            for i in 0..<30 {
                guard let date = calendar.date(byAdding: .day, value: i, to: Date()) else { continue }
                
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                dateComponents.hour = 19
                dateComponents.minute = 0
                
                let content = UNMutableNotificationContent()
                content.title = "Calorie Check-In"
                content.body = "Log your nutrition and stay consistent! 📝"
                content.sound = .default
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let identifier = "sculpty-daily-calorie-reminder-\(dateComponents.year!)-\(dateComponents.month!)-\(dateComponents.day!)" // swiftlint:disable:this line_length force_unwrapping
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
            
            scheduleGentleReminder()
        }
    }
    
    private func scheduleGentleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "How's your fitness journey going?"
        content.body = "Check your progress and start your next workout! 💪"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2678400, repeats: false)
        let request = UNNotificationRequest(identifier: "sculpty-gentle-checkin", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
