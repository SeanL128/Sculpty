//
//  UserKeys.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/10/25.
//

import Foundation

enum UserKeys: String, CaseIterable {
    case appearance = "APPEARANCE"
    case accent = "ACCENT_COLOR"
    case dailyCalories = "DAILY_CALORIES"
    case disableAutoLock = "DISABLE_AUTO_LOCK"
    case includeWarmUp = "INCLUDE_WARM_UP"
    case includeDropSet = "INCLUDE_DROP_SET"
    case includeCoolDown = "INCLUDE_COOL_DOWN"
    case lastCheckedDate = "LAST_CHECKED_DATE"
    case onboarded = "ONBOARDED"
    case show1RM = "SHOW_1RM"
    case showRir = "SHOW_RIR"
    case showSetTimer = "SHOW_SET_TIMER"
    case showTempo = "SHOW_TEMPO"
    case units = "UNITS"
    
    // Default Set
    case defaultDistance = "DEFAULT_DISTANCE"
    case defaultMeasurement = "DEFAULT_MEASUREMENT"
    case defaultReps = "DEFAULT_REPS"
    case defaultRir = "DEFAULT_RIR"
    case defaultTime = "DEFAULT_TIME"
    case defaultType = "DEFAULT_TYPE"
    case defaultDistanceUnits = "DEFAULT_DISTANCE_UNITS"
    case defaultWeightUnits = "DEFAULT_WEIGHT_UNITS"
    case defaultWeight = "DEFAULT_WEIGHT"
}
