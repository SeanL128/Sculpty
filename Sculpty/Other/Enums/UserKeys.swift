//
//  UserKeys.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/10/25.
//

import Foundation

enum UserKeys: String, CaseIterable {
    case accentColorHex = "ACCENT_COLOR_HEX"
    case appearance = "APPEARANCE"
    case dailyCalories = "DAILY_CALORIES"
    case gender = "GENDER"
    case includeWarmUp = "INCLUDE_WARM_UP"
    case includeDropSet = "INCLUDE_DROP_SET"
    case includeCoolDown = "INCLUDE_COOL_DOWN"
    case longestWorkoutStreak = "LONGEST_WORKOUT_STREAK"
    case onboarded = "ONBOARDED"
    case show1RM = "SHOW_1RM"
    case showRir = "SHOW_RIR"
    case showSetTimer = "SHOW_SET_TIMER"
    case showTempo = "SHOW_TEMPO"
    case targetWeeklyWorkouts = "TARGET_WEEKLY_WORKOUTS"
    case units = "UNITS"
    
    // Notifications
    case enableNotifications = "ENABLE_NOTIFICATIONS"
    
    case enableCaloriesNotifications = "ENABLE_CALORIES_NOTIFICATIONS"
    case calorieReminderHour = "CALORIE_REMINDER_HOUR"
    case calorieReminderMinute = "CALORIE_REMINDER_MINUTE"
    
    case enableMeasurementsNotifications = "ENABLE_MEASUREMENTS_NOTIFICATIONS"
    case measurementReminderWeekday = "MEASUREMENT_REMINDER_WEEKDAY"
    case measurementReminderHour = "MEASUREMENT_REMINDER_HOUR"
    case measurementReminderMinute = "MEASUREMENT_REMINDER_MINUTE"
}
