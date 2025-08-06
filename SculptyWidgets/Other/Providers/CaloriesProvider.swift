//
//  CaloriesProvider.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import WidgetKit

struct CaloriesProvider: TimelineProvider {
    func placeholder(in context: Context) -> CaloriesEntry {
        CaloriesEntry(
            date: Date(),
            totalCalories: 1852,
            targetCalories: 2000,
            carbs: 185,
            protein: 142,
            fat: 68
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CaloriesEntry) -> ()) {
        let entry = CaloriesEntry(
            date: Date(),
            totalCalories: 1852,
            targetCalories: 2200,
            carbs: 185,
            protein: 142,
            fat: 68
        )
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getCurrentCaloriesData()
        let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()))
        
        completion(timeline)
    }
    
    private func getCurrentCaloriesData() -> CaloriesEntry {
        guard let sharedDefaults = UserDefaults(suiteName: "group.app.sculpty.SculptyApp") else {
            return CaloriesEntry(
                date: Date(),
                totalCalories: 0,
                targetCalories: 2200,
                carbs: 0,
                protein: 0,
                fat: 0
            )
        }
        
        let totalCalories = sharedDefaults.integer(forKey: UserKeys.widgetCaloriesLogged.rawValue)
        let targetCalories = sharedDefaults.integer(forKey: UserKeys.widgetCaloriesTarget.rawValue)
        let carbs = sharedDefaults.integer(forKey: UserKeys.widgetCarbs.rawValue)
        let protein = sharedDefaults.integer(forKey: UserKeys.widgetProtein.rawValue)
        let fat = sharedDefaults.integer(forKey: UserKeys.widgetFat.rawValue)
        
        return CaloriesEntry(
            date: Date(),
            totalCalories: totalCalories,
            targetCalories: targetCalories > 0 ? targetCalories : 2200,
            carbs: carbs,
            protein: protein,
            fat: fat
        )
    }
}
