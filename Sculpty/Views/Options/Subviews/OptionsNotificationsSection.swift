//
//  OptionsNotificationsSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI
import UIKit

struct OptionsNotificationsSection: View {
    @EnvironmentObject private var settings: CloudSettings
    
    @State private var tempCalorieTime = Date()
    
    @State private var tempMeasurementTime = Date()
    @State private var tempMeasurementWeekday = 1
    
    private var calorieTime: String {
        let time = settings.getCalorieReminderTime()
        let date = Calendar.current.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    private var measurementTime: String {
        let time = settings.getMeasurementReminderTime()
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.weekdaySymbols = Calendar.current.shortWeekdaySymbols
        let weekdayName = weekdayFormatter.weekdaySymbols[time.weekday - 1]
        
        let date = Calendar.current.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: Date()) ?? Date()
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        return "\(weekdayName) \(timeFormatter.string(from: date))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            OptionsSectionHeader(title: "Notifications", image: "bell")
            
            OptionsToggleRow(
                title: "Enable Notifications",
                isOn: $settings.enableNotifications
            )
            .onChange(of: settings.enableNotifications) {
                if settings.enableNotifications {
                    handleNotificationToggle()
                }
            }
            
            if settings.enableNotifications {
                OptionsToggleRow(
                    title: "Daily Calorie Reminders",
                    isOn: $settings.enableCaloriesNotifications
                )
                
                if settings.enableCaloriesNotifications {
                    OptionsPickerRow(
                        title: "Calories Reminder Time",
                        text: calorieTime,
                        popup: TimeSelectionPopup(
                            title: "Calories Reminder Time",
                            time: $tempCalorieTime
                        ),
                        onDismiss: saveCalorieTime
                    )
                    .animation(.easeInOut(duration: 0.3), value: settings.enableCaloriesNotifications)
                }
            
                OptionsToggleRow(
                    title: "Weekly Measurement Reminders",
                    isOn: $settings.enableMeasurementsNotifications
                )
                
                if settings.enableMeasurementsNotifications {
                    OptionsPickerRow(
                        title: "Measurement Reminder Time",
                        text: measurementTime,
                        popup: TimeSelectionPopup(
                            title: "Measurement Reminder Time",
                            day: $tempMeasurementWeekday,
                            time: $tempMeasurementTime
                        ),
                        onDismiss: saveMeasurementTime
                    )
                    .animation(.easeInOut(duration: 0.3), value: settings.enableMeasurementsNotifications)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.3), value: settings.enableNotifications)
        .onAppear {
            setupTempTimes()
        }
    }
    
    private func handleNotificationToggle() {
        NotificationManager.shared.requestPermissionIfNeeded { granted in
            DispatchQueue.main.async {
                if !granted {
                    settings.enableNotifications = false
                    
                    Popup.show(content: {
                        InfoPopup(
                            title: "Enable Notifications",
                            text: "To receive reminders, please enable notifications in Settings > Sculpty > Notifications" // swiftlint:disable:this line_length
                        )
                    })
                    
                    openSettings()
                }
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func setupTempTimes() {
        let calorieTime = settings.getCalorieReminderTime()
        
        tempCalorieTime = Calendar.current.date(
            bySettingHour: calorieTime.hour,
            minute: calorieTime.minute,
            second: 0,
            of: Date()
        ) ?? Date()
        
        let measurementTime = settings.getMeasurementReminderTime()
        tempMeasurementTime = Calendar.current.date(
            bySettingHour: measurementTime.hour,
            minute: measurementTime.minute,
            second: 0,
            of: Date()
        ) ?? Date()
        tempMeasurementWeekday = measurementTime.weekday
    }
    
    private func saveCalorieTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: tempCalorieTime)
        
        settings.setCalorieReminderTime(
            hour: components.hour ?? 19,
            minute: components.minute ?? 0
        )
    }
    
    private func saveMeasurementTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: tempMeasurementTime)
        
        settings.setMeasurementReminderTime(
            weekday: tempMeasurementWeekday,
            hour: components.hour ?? 9,
            minute: components.minute ?? 0
        )
    }
}
