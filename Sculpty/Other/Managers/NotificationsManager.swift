//
//  NotificationManager.swift
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
    
    private enum NotificationIdentifiers {
        static let dailyCaloriePrefix = "sculpty-daily-calorie-reminder"
        static let weeklyMeasurement = "sculpty-weekly-measurement"
        static let gentleReminder = "sculpty-gentle-checkin"
        static let workoutReminder = "sculpty-workout-reminder"
        static let streakReminder = "sculpty-streak-reminder"
    }
    
    private init() {}
    
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
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .badge, .sound]
                ) { granted, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            debugLog("Notification permission error: \(error.localizedDescription)")
                        }
                        completion(granted)
                    }
                }
            case .authorized, .provisional:
                completion(true)
            case .denied:
                completion(false)
            }
        }
    }
    
    func scheduleAllNotifications() {
        guard CloudSettings.shared.enableNotifications else { return }
        
        if CloudSettings.shared.enableCaloriesNotifications {
            scheduleDailyCalorieReminders()
        }
        
        if CloudSettings.shared.enableMeasurementsNotifications {
            scheduleWeeklyMeasurementReminders()
        }
    }
    
    func enableNotifications() {
        scheduleAllNotifications()
    }
    
    func disableNotifications() {
        cancelAllNotifications()
    }
    
    func enableCaloriesNotifications() {
        cancelCalorieNotifications()
        scheduleDailyCalorieReminders()
    }
    
    func disableCaloriesNotifications() {
        cancelCalorieNotifications()
    }
    
    func enableMeasurementsNotifications() {
        cancelMeasurementNotifications()
        scheduleWeeklyMeasurementReminders()
    }
    
    func disableMeasurementsNotifications() {
        cancelMeasurementNotifications()
    }
    
    private func scheduleDailyCalorieReminders() {
        guard CloudSettings.shared.enableCaloriesNotifications else { return }
        
        let calendar = Calendar.current
        let settings = CloudSettings.shared
        
        let hour = settings.calorieReminderHour ?? 19
        let minute = settings.calorieReminderMinute ?? 0
        
        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: i, to: Date()) else { continue }
            
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let content = UNMutableNotificationContent()
            content.title = "Calories Check-In"
            content.body = "Log your nutrition and stay consistent!"
            content.sound = .default
            content.categoryIdentifier = "CALORIE_REMINDER"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let identifier = "\(NotificationIdentifiers.dailyCaloriePrefix)-\(dateComponents.year!)-\(dateComponents.month!)-\(dateComponents.day!)" // swiftlint:disable:this line_length force_unwrapping
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    debugLog("Failed to schedule daily calorie reminder: \(error.localizedDescription)")
                }
            }
        }
        
        scheduleGentleReminder()
    }
    
    func cancelTodaysCalorieReminder() {
        let calendar = Calendar.current
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        let identifier = "\(NotificationIdentifiers.dailyCaloriePrefix)-\(today.year!)-\(today.month!)-\(today.day!)" // swiftlint:disable:this line_length force_unwrapping
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    private func scheduleWeeklyMeasurementReminders() {
        guard CloudSettings.shared.enableMeasurementsNotifications else { return }
        
        let settings = CloudSettings.shared
        
        let content = UNMutableNotificationContent()
        content.title = "Progress Check"
        content.body = "See how far you've come - record your measurements!"
        content.sound = .default
        content.categoryIdentifier = "MEASUREMENT_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.weekday = settings.measurementReminderWeekday ?? 1
        dateComponents.hour = settings.measurementReminderHour ?? 9
        dateComponents.minute = settings.measurementReminderMinute ?? 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationIdentifiers.weeklyMeasurement,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                debugLog("Failed to schedule weekly measurement reminder: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleGentleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "How's your fitness journey going?"
        content.body = "Check your progress and start your next workout! 💪"
        content.sound = .default
        content.categoryIdentifier = "GENTLE_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2678400, repeats: false)
        let request = UNNotificationRequest(
            identifier: NotificationIdentifiers.gentleReminder,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                debugLog("Failed to schedule gentle reminder: \(error.localizedDescription)")
            }
        }
    }
    
    private func cancelCalorieNotifications() {
        let calendar = Calendar.current
        var identifiers: [String] = []
        
        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: i, to: Date()) else { continue }
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let identifier = "\(NotificationIdentifiers.dailyCaloriePrefix)-\(dateComponents.year!)-\(dateComponents.month!)-\(dateComponents.day!)" // swiftlint:disable:this line_length force_unwrapping
            identifiers.append(identifier)
        }
        
        identifiers.append(NotificationIdentifiers.gentleReminder)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    private func cancelMeasurementNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifiers.weeklyMeasurement]
        )
    }
    
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
