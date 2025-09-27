//
//  CloudSettings.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/26/25.
//

import Foundation
import Combine

class CloudSettings: ObservableObject {
    static let shared: CloudSettings = CloudSettings()
    
    private let store = NSUbiquitousKeyValueStore.default
    private let userDefaults = UserDefaults.standard
    
    init() {
        registerDefaults()
        
        syncFromCloud()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cloudStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store
        )
        
        if FileManager.default.ubiquityIdentityToken != nil {
            store.synchronize()
        } else {
            debugLog("iCloud not available - skipping sync")
        }
    }
    
    private func registerDefaults() {
        let defaults: [String: Any] = [
            UserKeys.accentColorHex.rawValue: "#2563EB",
            UserKeys.dailyCalories.rawValue: 2000,
            UserKeys.enableAutoBackup.rawValue: false,
            UserKeys.enableHaptics.rawValue: true,
            UserKeys.enableLiveActivities.rawValue: true,
            UserKeys.enableToasts.rawValue: true,
            UserKeys.gender.rawValue: "Male",
            UserKeys.includeWarmUp.rawValue: true,
            UserKeys.includeDropSet.rawValue: true,
            UserKeys.includeCoolDown.rawValue: true,
            UserKeys.longestWorkoutStreak.rawValue: 0,
            UserKeys.onboarded.rawValue: false,
            UserKeys.show1RM.rawValue: false,
            UserKeys.showRir.rawValue: false,
            UserKeys.showSetTimer.rawValue: false,
            UserKeys.showTempo.rawValue: false,
            UserKeys.targetWeeklyWorkouts.rawValue: 3,
            UserKeys.units.rawValue: "Imperial",
            UserKeys.enableNotifications.rawValue: false,
            UserKeys.enableCaloriesNotifications.rawValue: false,
            UserKeys.calorieReminderHour.rawValue: 19,
            UserKeys.calorieReminderMinute.rawValue: 0,
            UserKeys.enableMeasurementsNotifications.rawValue: false,
            UserKeys.measurementReminderWeekday.rawValue: 1,
            UserKeys.measurementReminderHour.rawValue: 9,
            UserKeys.measurementReminderMinute.rawValue: 0
        ]
        
        userDefaults.register(defaults: defaults)
        
        for (key, value) in defaults where store.object(forKey: key) == nil {
            store.set(value, forKey: key)
        }
    }
    
    func resetAllSettings() {
        for key in UserKeys.allCases {
            userDefaults.removeObject(forKey: key.rawValue)
        }
        
        for key in UserKeys.allCases {
            store.removeObject(forKey: key.rawValue)
        }
        
        registerDefaults()
        
        if FileManager.default.ubiquityIdentityToken != nil {
            store.synchronize()
        }
        
        objectWillChange.send()
    }
    
    @objc private func cloudStoreDidChange(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.syncFromCloud()
        }
    }
    
    private func syncFromCloud() {
        for key in UserKeys.allCases {
            let cloudValue = store.object(forKey: key.rawValue)
            if cloudValue != nil {
                userDefaults.set(cloudValue, forKey: key.rawValue)
            }
        }
    }
    
    private func setValue<T: Equatable>(_ value: T, for key: UserKeys) {
        let currentValue = userDefaults.object(forKey: key.rawValue) as? T
        guard currentValue != value else { return }
        
        userDefaults.set(value, forKey: key.rawValue)
        store.set(value, forKey: key.rawValue)
    }
    
    var accentColorHex: String {
        get { userDefaults.string(forKey: UserKeys.accentColorHex.rawValue) ?? "#2563EB" }
        set {
            objectWillChange.send()
            
            setValue(newValue, for: .accentColorHex)
        }
    }
    
    var gender: String {
        get { userDefaults.string(forKey: UserKeys.gender.rawValue) ?? "notSpecified" }
        set {
            objectWillChange.send()
            setValue(newValue, for: .gender)
        }
    }
    
    var units: String {
        get { userDefaults.string(forKey: UserKeys.units.rawValue) ?? "metric" }
        set {
            objectWillChange.send()
            setValue(newValue, for: .units)
        }
    }
    
    var dailyCalories: Int {
        get { userDefaults.integer(forKey: UserKeys.dailyCalories.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .dailyCalories)
        }
    }
    
    var dailyCaloriesString: String {
        get { String(dailyCalories) }
        set {
            if let intValue = Int(newValue) {
                objectWillChange.send()
                dailyCalories = intValue
            }
        }
    }
    
    var targetWeeklyWorkouts: Int {
        get { userDefaults.integer(forKey: UserKeys.targetWeeklyWorkouts.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .targetWeeklyWorkouts)
        }
    }
    
    var targetWeeklyWorkoutsString: String {
        get { String(targetWeeklyWorkouts) }
        set {
            if let intValue = Int(newValue) {
                objectWillChange.send()
                targetWeeklyWorkouts = intValue
            }
        }
    }
    
    var longestWorkoutStreak: Int {
        get { userDefaults.integer(forKey: UserKeys.longestWorkoutStreak.rawValue) }
        set { setValue(newValue, for: .longestWorkoutStreak) }
    }
    
    var includeWarmUp: Bool {
        get { userDefaults.bool(forKey: UserKeys.includeWarmUp.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .includeWarmUp)
        }
    }
    
    var includeDropSet: Bool {
        get { userDefaults.bool(forKey: UserKeys.includeDropSet.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .includeDropSet)
        }
    }
    
    var includeCoolDown: Bool {
        get { userDefaults.bool(forKey: UserKeys.includeCoolDown.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .includeCoolDown)
        }
    }
    
    var onboarded: Bool {
        get { userDefaults.bool(forKey: UserKeys.onboarded.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .onboarded)
        }
    }
    
    var show1RM: Bool {
        get { userDefaults.bool(forKey: UserKeys.show1RM.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .show1RM)
        }
    }
    
    var showRir: Bool {
        get { userDefaults.bool(forKey: UserKeys.showRir.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .showRir)
        }
    }
    
    var showSetTimer: Bool {
        get { userDefaults.bool(forKey: UserKeys.showSetTimer.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .showSetTimer)
        }
    }
    
    var showTempo: Bool {
        get { userDefaults.bool(forKey: UserKeys.showTempo.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .showTempo)
        }
    }
    
    var enableAutoBackup: Bool {
        get { userDefaults.bool(forKey: UserKeys.enableAutoBackup.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .enableAutoBackup)
        }
    }
    
    var enableHaptics: Bool {
        get { userDefaults.bool(forKey: UserKeys.enableHaptics.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .enableHaptics)
        }
    }
    
    var enableLiveActivities: Bool {
        get { userDefaults.bool(forKey: UserKeys.enableLiveActivities.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .enableLiveActivities)
        }
    }
    
    var enableToasts: Bool {
        get { userDefaults.bool(forKey: UserKeys.enableToasts.rawValue) }
        set {
            objectWillChange.send()
            setValue(newValue, for: .enableToasts)
        }
    }
    
    var enableNotifications: Bool {
        get { userDefaults.bool(forKey: UserKeys.enableNotifications.rawValue) }
        set {
            objectWillChange.send()
            
            setValue(newValue, for: .enableNotifications)
            
            if newValue {
                Task { @MainActor in
                    NotificationManager.shared.enableNotifications()
                }
            } else {
                NotificationManager.shared.disableNotifications()
            }
        }
    }
    
    var enableCaloriesNotifications: Bool {
        get { userDefaults.bool(forKey: UserKeys.enableCaloriesNotifications.rawValue) }
        set {
            objectWillChange.send()
            
            setValue(newValue, for: .enableCaloriesNotifications)
            
            if newValue {
                Task { @MainActor in
                    NotificationManager.shared.enableCaloriesNotifications()
                }
            } else {
                NotificationManager.shared.disableCaloriesNotifications()
            }
        }
    }
    
    var enableMeasurementsNotifications: Bool {
        get { userDefaults.bool(forKey: UserKeys.enableMeasurementsNotifications.rawValue) }
        set {
            objectWillChange.send()
            
            setValue(newValue, for: .enableMeasurementsNotifications)
            
            if newValue {
                Task { @MainActor in
                    NotificationManager.shared.enableMeasurementsNotifications()
                }
            } else {
                NotificationManager.shared.disableMeasurementsNotifications()
            }
        }
    }
    
    var calorieReminderHour: Int? {
        get {
            let value = userDefaults.integer(forKey: UserKeys.calorieReminderHour.rawValue)
            return value == 0 ? nil : value
        }
        set {
            objectWillChange.send()
            setValue(newValue ?? 19, for: .calorieReminderHour)
            
            if enableCaloriesNotifications {
                Task { @MainActor in
                    NotificationManager.shared.enableCaloriesNotifications()
                }
            }
        }
    }
    
    var calorieReminderMinute: Int? {
        get {
            let value = userDefaults.integer(forKey: UserKeys.calorieReminderMinute.rawValue)
            return value == 0 ? nil : value
        }
        set {
            objectWillChange.send()
            setValue(newValue ?? 0, for: .calorieReminderMinute)
            
            if enableCaloriesNotifications {
                Task { @MainActor in
                    NotificationManager.shared.enableCaloriesNotifications()
                }
            }
        }
    }
    
    var measurementReminderWeekday: Int? {
        get {
            let value = userDefaults.integer(forKey: UserKeys.measurementReminderWeekday.rawValue)
            return value == 0 ? nil : value
        }
        set {
            objectWillChange.send()
            setValue(newValue ?? 1, for: .measurementReminderWeekday)
            
            if enableMeasurementsNotifications {
                Task { @MainActor in
                    NotificationManager.shared.enableMeasurementsNotifications()
                }
            }
        }
    }
    
    var measurementReminderHour: Int? {
        get {
            let value = userDefaults.integer(forKey: UserKeys.measurementReminderHour.rawValue)
            return value == 0 ? nil : value
        }
        set {
            objectWillChange.send()
            setValue(newValue ?? 9, for: .measurementReminderHour)
            
            if enableMeasurementsNotifications {
                Task { @MainActor in
                    NotificationManager.shared.enableMeasurementsNotifications()
                }
            }
        }
    }
    
    var measurementReminderMinute: Int? {
        get {
            let value = userDefaults.integer(forKey: UserKeys.measurementReminderMinute.rawValue)
            return value == 0 ? nil : value
        }
        set {
            objectWillChange.send()
            setValue(newValue ?? 0, for: .measurementReminderMinute)
            
            if enableMeasurementsNotifications {
                Task { @MainActor in
                    NotificationManager.shared.enableMeasurementsNotifications()
                }
            }
        }
    }
    
    func getCalorieReminderTime() -> (hour: Int, minute: Int) {
        return (
            hour: calorieReminderHour ?? 19,
            minute: calorieReminderMinute ?? 0
        )
    }
    
    func getMeasurementReminderTime() -> (weekday: Int, hour: Int, minute: Int) {
        return (
            weekday: measurementReminderWeekday ?? 1,
            hour: measurementReminderHour ?? 9,
            minute: measurementReminderMinute ?? 0
        )
    }
    
    func setCalorieReminderTime(hour: Int, minute: Int) {
        calorieReminderHour = hour
        calorieReminderMinute = minute
    }
    
    func setMeasurementReminderTime(weekday: Int, hour: Int, minute: Int) {
        measurementReminderWeekday = weekday
        measurementReminderHour = hour
        measurementReminderMinute = minute
    }
    
    var weeklyNutritionSearches: Int {
        get { userDefaults.integer(forKey: "WEEKLY_NUTRITION_SEARCHES") }
        set {
            objectWillChange.send()
            userDefaults.set(newValue, forKey: "WEEKLY_NUTRITION_SEARCHES")
        }
    }
    
    var weeklyBarcodeScans: Int {
        get { userDefaults.integer(forKey: "WEEKLY_BARCODE_SCANS") }
        set {
            objectWillChange.send()
            userDefaults.set(newValue, forKey: "WEEKLY_BARCODE_SCANS")
        }
    }
    
    var lastNutritionResetDate: Date? {
        get { userDefaults.object(forKey: "LAST_NUTRITION_RESET_DATE") as? Date }
        set {
            objectWillChange.send()
            userDefaults.set(newValue, forKey: "LAST_NUTRITION_RESET_DATE")
        }
    }
    
    func checkAndResetWeeklyUsage() {
        let now = Date()
        
        if lastNutritionResetDate == nil {
            lastNutritionResetDate = now
            return
        }
        
        guard let lastReset = lastNutritionResetDate else { return }
        
        let calendar = Calendar.current
        let weeksSinceReset = calendar.dateComponents([.weekOfYear], from: lastReset, to: now).weekOfYear ?? 0
        
        if weeksSinceReset > 1 {
            weeklyNutritionSearches = 0
            weeklyBarcodeScans = 0
            lastNutritionResetDate = now
            
            debugLog("Weekly usage counters reset")
        }
    }
}
