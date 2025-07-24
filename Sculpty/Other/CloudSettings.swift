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
        
        store.synchronize()
    }
    
    private func registerDefaults() {
        let defaults: [String: Any] = [
            UserKeys.accentColorHex.rawValue: "#2B7EFF",
            UserKeys.appearance.rawValue: "Automatic",
            UserKeys.dailyCalories.rawValue: 2000,
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
            UserKeys.enableNotifications.rawValue: true,
            UserKeys.enableCaloriesNotifications.rawValue: true,
            UserKeys.calorieReminderHour.rawValue: 19,
            UserKeys.calorieReminderMinute.rawValue: 0,
            UserKeys.enableMeasurementsNotifications.rawValue: true,
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
        
        store.synchronize()
        
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
    
    var appearance: Appearance {
        get {
            let rawValue = userDefaults.string(forKey: UserKeys.appearance.rawValue) ?? Appearance.automatic.rawValue
            return Appearance(rawValue: rawValue) ?? .automatic
        }
        set {
            objectWillChange.send()
            setValue(newValue.rawValue, for: .appearance)
        }
    }
    
    var accentColorHex: String {
        get { userDefaults.string(forKey: UserKeys.accentColorHex.rawValue) ?? "#2B7EFF" }
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
    
    var enableNotifications: Bool {
        get { userDefaults.bool(forKey: UserKeys.enableNotifications.rawValue) }
        set {
            objectWillChange.send()
            
            setValue(newValue, for: .enableNotifications)
            
            if newValue {
                NotificationManager.shared.enableNotifications()
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
                NotificationManager.shared.enableCaloriesNotifications()
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
                NotificationManager.shared.enableMeasurementsNotifications()
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
                NotificationManager.shared.enableCaloriesNotifications()
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
                NotificationManager.shared.enableCaloriesNotifications()
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
                NotificationManager.shared.enableMeasurementsNotifications()
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
                NotificationManager.shared.enableMeasurementsNotifications()
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
                NotificationManager.shared.enableMeasurementsNotifications()
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
}
