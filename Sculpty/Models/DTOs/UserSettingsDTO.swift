//
//  UserSettingsDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/2/25.
//

import Foundation

struct UserSettingsDTO: Codable {
    var dailyCalories: Int?
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
    
    init(from settings: CloudSettings) {
        self.dailyCalories = UserDefaults.standard.object(forKey: UserKeys.dailyCalories.rawValue) as? Int
        self.gender = settings.gender
        self.includeWarmUp = UserDefaults.standard.object(forKey: UserKeys.includeWarmUp.rawValue) as? Bool
        self.includeDropSet = UserDefaults.standard.object(forKey: UserKeys.includeDropSet.rawValue) as? Bool
        self.includeCoolDown = UserDefaults.standard.object(forKey: UserKeys.includeCoolDown.rawValue) as? Bool
        self.longestWorkoutStreak = UserDefaults.standard.object(forKey: UserKeys.longestWorkoutStreak.rawValue) as? Int
        self.onboarded = UserDefaults.standard.object(forKey: UserKeys.onboarded.rawValue) as? Bool
        self.show1RM = UserDefaults.standard.object(forKey: UserKeys.show1RM.rawValue) as? Bool
        self.showRir = UserDefaults.standard.object(forKey: UserKeys.showRir.rawValue) as? Bool
        self.showSetTimer = UserDefaults.standard.object(forKey: UserKeys.showSetTimer.rawValue) as? Bool
        self.showTempo = UserDefaults.standard.object(forKey: UserKeys.showTempo.rawValue) as? Bool
        self.targetWeeklyWorkouts = UserDefaults.standard.object(forKey: UserKeys.targetWeeklyWorkouts.rawValue) as? Int
        self.units = settings.units
    }
    
    func applyTo(settings: CloudSettings) {
        if let dailyCalories = dailyCalories {
            settings.dailyCalories = dailyCalories
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
    }
}
