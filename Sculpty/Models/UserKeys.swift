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
    case restEndTime = "REST_END_TIME"
    case showRir = "SHOW_RIR"
    case showTempo = "SHOW_TEMPO"
    case units = "UNITS"
    
    // Default Set
    case defaultMeasurement = "DEFAULT_MEASUREMENT"
    case defaultReps = "DEFAULT_REPS"
    case defaultRir = "DEFAULT_RIR"
    case defaultType = "DEFAULT_TYPE"
    case defaultUnits = "DEFAULT_UNITS"
    case defaultWeight = "DEFAULT_WEIGHT"
}
