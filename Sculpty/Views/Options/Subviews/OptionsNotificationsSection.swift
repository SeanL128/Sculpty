//
//  OptionsNotificationsSection.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsNotificationsSection: View {
    @EnvironmentObject private var settings: CloudSettings
    
    @StateObject private var storeManager: StoreKitManager = StoreKitManager.shared
    
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
        VStack(alignment: .leading, spacing: .spacingS) {
            OptionsSectionHeader(title: "Notifications", image: "bell")
            
            VStack(alignment: .leading, spacing: .listSpacing) {
                if storeManager.hasPremiumAccess {
                    OptionsToggleRow(
                        text: "Enable Notifications",
                        isOn: $settings.enableNotifications
                    )
                    .onChange(of: settings.enableNotifications) {
                        if settings.enableNotifications {
                            handleNotificationToggle()
                        }
                    }
                } else {
                    NavigationLink {
                        UpgradeView()
                    } label: {
                        HStack(alignment: .center, spacing: .spacingXS) {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text("Enable Notifications")
                                    .bodyText()
                                    .secondaryColor()
                                
                                Image(systemName: "crown.fill")
                                    .bodyImage()
                                    .accentColor()
                            }
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 40, style: .continuous)
                                .stroke(ColorManager.border, lineWidth: 2)
                                .frame(width: 45, height: 25)
                                .background(ColorManager.background)
                                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                                .overlay(alignment: .center) {
                                    Circle()
                                        .frame(width: 19, height: 19)
                                        .foregroundStyle(ColorManager.text)
                                        .offset(x: -9)
                                }
                        }
                    }
                    .hapticButton(.selection)
                }
                
                if !storeManager.hasPremiumAccess {
                    NavigationLink {
                        UpgradeView()
                    } label: {
                        HStack(alignment: .center, spacing: .spacingXS) {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text("Daily Calorie Reminders")
                                    .bodyText()
                                    .secondaryColor()
                                
                                Image(systemName: "crown.fill")
                                    .bodyImage()
                                    .accentColor()
                            }
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 40, style: .continuous)
                                .stroke(ColorManager.border, lineWidth: 2)
                                .frame(width: 45, height: 25)
                                .background(ColorManager.background)
                                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                                .overlay(alignment: .center) {
                                    Circle()
                                        .frame(width: 19, height: 19)
                                        .foregroundStyle(ColorManager.text)
                                        .offset(x: -9)
                                }
                        }
                    }
                    .hapticButton(.selection)
                    
                    NavigationLink {
                        UpgradeView()
                    } label: {
                        HStack(alignment: .center, spacing: .spacingXS) {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text("Weekly Measurement Reminders")
                                    .bodyText()
                                    .secondaryColor()
                                
                                Image(systemName: "crown.fill")
                                    .bodyImage()
                                    .accentColor()
                            }
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 40, style: .continuous)
                                .stroke(ColorManager.border, lineWidth: 2)
                                .frame(width: 45, height: 25)
                                .background(ColorManager.background)
                                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                                .overlay(alignment: .center) {
                                    Circle()
                                        .frame(width: 19, height: 19)
                                        .foregroundStyle(ColorManager.text)
                                        .offset(x: -9)
                                }
                        }
                    }
                    .hapticButton(.selection)
                } else if settings.enableNotifications {
                    OptionsToggleRow(
                        text: "Daily Calorie Reminders",
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
                    }
                
                    OptionsToggleRow(
                        text: "Weekly Measurement Reminders",
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
                    }
                }
            }
            .card()
        }
        .frame(maxWidth: .infinity)
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
