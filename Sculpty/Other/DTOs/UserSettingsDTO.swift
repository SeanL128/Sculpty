//
//  UserSettingsDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/2/25.
//

import Foundation

struct UserSettingsDTO: Codable {
    var accentColorHex: String?
    var dailyCalories: Int?
    var enableAutoBackup: Bool?
    var enableHaptics: Bool?
    var enableLiveActivities: Bool?
    var enableToasts: Bool?
    var gender: String?
    var includeWarmUp: Bool?
    var includeDropSet: Bool?
    var includeCoolDown: Bool?
    var longestWorkoutStreak: Int?
    var onboarded: Bool?
    var show1RM: Bool?
    var showRir: Bool?
    var showSetTimer: Bool?
    var showTempo: Bool?
    var targetWeeklyWorkouts: Int?
    var units: String?
    var lastNutritionResetDate: Date?
    var weeklyBarcodeScans: Int?
    var weeklyNutritionSearches: Int?
    var enableNotifications: Bool?
    var enableCaloriesNotifications: Bool?
    var calorieReminderHour: Int?
    var calorieReminderMinute: Int?
    var enableMeasurementsNotifications: Bool?
    var measurementReminderWeekday: Int?
    var measurementReminderHour: Int?
    var measurementReminderMinute: Int?
    
    init(from settings: CloudSettings) {
        self.accentColorHex = settings.accentColorHex
        self.dailyCalories = settings.dailyCalories
        self.enableAutoBackup = settings.enableAutoBackup
        self.enableHaptics = settings.enableHaptics
        self.enableLiveActivities = settings.enableLiveActivities
        self.enableToasts = settings.enableToasts
        self.gender = settings.gender
        self.includeWarmUp = settings.includeWarmUp
        self.includeDropSet = settings.includeDropSet
        self.includeCoolDown = settings.includeCoolDown
        self.longestWorkoutStreak = settings.longestWorkoutStreak
        self.onboarded = settings.onboarded
        self.show1RM = settings.show1RM
        self.showRir = settings.showRir
        self.showSetTimer = settings.showSetTimer
        self.showTempo = settings.showTempo
        self.targetWeeklyWorkouts = settings.targetWeeklyWorkouts
        self.units = settings.units
        self.lastNutritionResetDate = settings.lastNutritionResetDate
        self.weeklyBarcodeScans = settings.weeklyBarcodeScans
        self.weeklyNutritionSearches = settings.weeklyNutritionSearches
        self.enableNotifications = settings.enableNotifications
        self.enableCaloriesNotifications = settings.enableCaloriesNotifications
        self.calorieReminderHour = settings.calorieReminderHour
        self.calorieReminderMinute = settings.calorieReminderMinute
        self.enableMeasurementsNotifications = settings.enableMeasurementsNotifications
        self.measurementReminderWeekday = settings.measurementReminderWeekday
        self.measurementReminderHour = settings.measurementReminderHour
        self.measurementReminderMinute = settings.measurementReminderMinute
    }
    
    func applyTo(settings: CloudSettings) {
        if let accentColorHex = accentColorHex {
            settings.accentColorHex = accentColorHex
        }
        
        if let dailyCalories = dailyCalories {
            settings.dailyCalories = dailyCalories
        }
        
        if let enableAutoBackup = enableAutoBackup {
            settings.enableAutoBackup = enableAutoBackup
        }
        
        if let enableHaptics = enableHaptics {
            settings.enableHaptics = enableHaptics
        }
        
        if let enableLiveActivities = enableLiveActivities {
            settings.enableLiveActivities = enableLiveActivities
        }
        
        if let enableToasts = enableToasts {
            settings.enableToasts = enableToasts
        }
        
        if let gender = gender {
            settings.gender = gender
        }
        
        if let includeWarmUp = includeWarmUp {
            settings.includeWarmUp = includeWarmUp
        }
        
        if let includeDropSet = includeDropSet {
            settings.includeDropSet = includeDropSet
        }
        
        if let includeCoolDown = includeCoolDown {
            settings.includeCoolDown = includeCoolDown
        }
        
        if let longestWorkoutStreak = longestWorkoutStreak {
            settings.longestWorkoutStreak = longestWorkoutStreak
        }
        
        if let onboarded = onboarded {
            settings.onboarded = onboarded
        }
        
        if let show1RM = show1RM {
            settings.show1RM = show1RM
        }
        
        if let showRir = showRir {
            settings.showRir = showRir
        }
        
        if let showSetTimer = showSetTimer {
            settings.showSetTimer = showSetTimer
        }
        
        if let showTempo = showTempo {
            settings.showTempo = showTempo
        }
        
        if let targetWeeklyWorkouts = targetWeeklyWorkouts {
            settings.targetWeeklyWorkouts = targetWeeklyWorkouts
        }
        
        if let units = units {
            settings.units = units
        }
        
        if let enableNotifications = enableNotifications {
            settings.enableNotifications = enableNotifications
        }
        
        if let enableCaloriesNotifications = enableCaloriesNotifications {
            settings.enableCaloriesNotifications = enableCaloriesNotifications
        }
        
        if let calorieReminderHour = calorieReminderHour {
            settings.calorieReminderHour = calorieReminderHour
        }
        
        if let calorieReminderMinute = calorieReminderMinute {
            settings.calorieReminderMinute = calorieReminderMinute
        }
        
        if let enableMeasurementsNotifications = enableMeasurementsNotifications {
            settings.enableMeasurementsNotifications = enableMeasurementsNotifications
        }
        
        if let measurementReminderWeekdayIndex = measurementReminderWeekday {
            settings.measurementReminderWeekday = measurementReminderWeekdayIndex
        }
        
        if let measurementReminderHour = measurementReminderHour {
            settings.measurementReminderHour = measurementReminderHour
        }
        
        if let measurementReminderMinute = measurementReminderMinute {
            settings.measurementReminderMinute = measurementReminderMinute
        }
        
        if let lastNutritionResetDate = lastNutritionResetDate {
            settings.lastNutritionResetDate = lastNutritionResetDate
        }
        
        if let weeklyBarcodeScans = weeklyBarcodeScans {
            settings.weeklyBarcodeScans = weeklyBarcodeScans
        }
        
        if let weeklyNutritionSearches = weeklyNutritionSearches {
            settings.weeklyNutritionSearches = weeklyNutritionSearches
        }
    }
}
