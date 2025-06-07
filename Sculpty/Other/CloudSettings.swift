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
            UserKeys.units.rawValue: "Imperial"
        ]
        
        userDefaults.register(defaults: defaults)
        
        for (key, value) in defaults {
            if store.object(forKey: key) == nil {
                store.set(value, forKey: key)
            }
        }
    }
    
    func resetAllSettings() {
        UserKeys.allCases.forEach {
            userDefaults.removeObject(forKey: $0.rawValue)
        }
        
        UserKeys.allCases.forEach {
            store.removeObject(forKey: $0.rawValue)
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
    
    private func setValue<T>(_ value: T, for key: UserKeys) {
        userDefaults.set(value, forKey: key.rawValue)
        store.set(value, forKey: key.rawValue)
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
}
