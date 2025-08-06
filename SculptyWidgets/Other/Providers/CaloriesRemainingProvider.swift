//
//  CaloriesRemainingProvider.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import WidgetKit

struct CaloriesRemainingProvider: TimelineProvider {
    func placeholder(in context: Context) -> CaloriesRemainingEntry {
        CaloriesRemainingEntry(date: Date(), caloriesRemaining: 348, targetCalories: 2200)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CaloriesRemainingEntry) -> ()) {
        let entry = CaloriesRemainingEntry(date: Date(), caloriesRemaining: 348, targetCalories: 2200)
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getCurrentRemainingCalories()
        let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()))
        
        completion(timeline)
    }
    
    private func getCurrentRemainingCalories() -> CaloriesRemainingEntry {
        guard let sharedDefaults = UserDefaults(suiteName: "group.app.sculpty.SculptyApp") else {
            return CaloriesRemainingEntry(date: Date(), caloriesRemaining: 2200, targetCalories: 2200)
        }
        
        let caloriesLogged = sharedDefaults.integer(forKey: UserKeys.widgetCaloriesLogged.rawValue)
        let targetCalories = sharedDefaults.integer(forKey: UserKeys.widgetCaloriesTarget.rawValue)
        
        let actualTarget = targetCalories > 0 ? targetCalories : 2200
        let caloriesRemaining = max(0, actualTarget - caloriesLogged)
        
        return CaloriesRemainingEntry(
            date: Date(),
            caloriesRemaining: caloriesRemaining,
            targetCalories: actualTarget
        )
    }
}
