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
    
    private init() { }
    
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
    
    @MainActor
    func scheduleAllNotifications() {
        guard StoreKitManager.shared.hasPremiumAccess, CloudSettings.shared.enableNotifications else { return }
        
        if CloudSettings.shared.enableCaloriesNotifications {
            scheduleDailyCalorieReminders()
        }
        
        if CloudSettings.shared.enableMeasurementsNotifications {
            scheduleWeeklyMeasurementReminders()
        }
    }
    
    @MainActor
    func enableNotifications() {
        if StoreKitManager.shared.hasPremiumAccess {
            scheduleAllNotifications()
        }
    }
    
    func disableNotifications() {
        cancelAllNotifications()
    }
    
    @MainActor
    func enableCaloriesNotifications() {
        if StoreKitManager.shared.hasPremiumAccess {
            cancelCalorieNotifications()
            
            scheduleDailyCalorieReminders()
        }
    }
    
    func disableCaloriesNotifications() {
        cancelCalorieNotifications()
    }
    
    @MainActor
    func enableMeasurementsNotifications() {
        if StoreKitManager.shared.hasPremiumAccess {
            cancelMeasurementNotifications()
            
            scheduleWeeklyMeasurementReminders()
        }
    }
    
    func disableMeasurementsNotifications() {
        cancelMeasurementNotifications()
    }
    
    @MainActor
    private func scheduleDailyCalorieReminders() {
        guard StoreKitManager.shared.hasPremiumAccess,
              CloudSettings.shared.enableNotifications,
              CloudSettings.shared.enableCaloriesNotifications else { return }
        
        let calendar = Calendar.current
        let settings = CloudSettings.shared
        
        let hour = settings.calorieReminderHour ?? 19
        let minute = settings.calorieReminderMinute ?? 0
        
        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: i, to: Date()) else { continue }
            
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            if let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day {
                let content = UNMutableNotificationContent()
                content.title = "Calories Check-In"
                content.body = "Log your nutrition and stay consistent!"
                content.sound = .default
                content.categoryIdentifier = "CALORIE_REMINDER"
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let identifier = "\(NotificationIdentifiers.dailyCaloriePrefix)-\(year)-\(month)-\(day)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        debugLog("Failed to schedule daily calorie reminder: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        scheduleGentleReminder()
    }
    
    func cancelTodaysCalorieReminder() {
        let calendar = Calendar.current
        let today = calendar.dateComponents([.year, .month, .day], from: Date())
        if let year = today.year, let month = today.month, let day = today.day {
            let identifier = "\(NotificationIdentifiers.dailyCaloriePrefix)-\(year)-\(month)-\(day)"
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        }
    }
    
    @MainActor
    private func scheduleWeeklyMeasurementReminders() {
        guard StoreKitManager.shared.hasPremiumAccess,
              CloudSettings.shared.enableNotifications,
              CloudSettings.shared.enableMeasurementsNotifications else { return }
        
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
    
    @MainActor
    private func scheduleGentleReminder() {
        guard StoreKitManager.shared.hasPremiumAccess, CloudSettings.shared.enableNotifications else { return }
        
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
            guard let year = dateComponents.year,
                  let month = dateComponents.month,
                  let day = dateComponents.day else { continue }
            
            let identifier = "\(NotificationIdentifiers.dailyCaloriePrefix)-\(year)-\(month)-\(day)"
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
