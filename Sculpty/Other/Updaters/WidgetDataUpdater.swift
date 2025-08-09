//
//  WidgetDataUpdater.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import Foundation
import WidgetKit

class WidgetDataUpdater {
    static let shared = WidgetDataUpdater()
    
    private init() { }
    
    func updateWidgetData(
        caloriesLogged: Int,
        targetCalories: Int,
        carbs: Int,
        protein: Int,
        fat: Int
    ) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.app.sculpty.SculptyApp") else { return }
        
        sharedDefaults.set(max(0, caloriesLogged), forKey: UserKeys.widgetCaloriesLogged.rawValue)
        sharedDefaults.set(max(0, targetCalories), forKey: UserKeys.widgetCaloriesTarget.rawValue)
        sharedDefaults.set(max(0, carbs), forKey: UserKeys.widgetCarbs.rawValue)
        sharedDefaults.set(max(0, protein), forKey: UserKeys.widgetProtein.rawValue)
        sharedDefaults.set(max(0, fat), forKey: UserKeys.widgetFat.rawValue)
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func updateFromCaloriesBreakdown(_ breakdown: (Int, Int, Int, Int), targetCalories: Int) {
        updateWidgetData(
            caloriesLogged: breakdown.0,
            targetCalories: targetCalories,
            carbs: breakdown.1,
            protein: breakdown.2,
            fat: breakdown.3
        )
    }
}
