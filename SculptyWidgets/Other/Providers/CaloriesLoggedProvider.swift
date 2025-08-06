//
//  CaloriesLoggedProvider.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import WidgetKit

struct CaloriesLoggedProvider: TimelineProvider {
    func placeholder(in context: Context) -> CaloriesLoggedEntry {
        CaloriesLoggedEntry(date: Date(), caloriesLogged: 1852)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CaloriesLoggedEntry) -> ()) {
        let entry = CaloriesLoggedEntry(date: Date(), caloriesLogged: 1852)
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getCurrentLoggedCalories()
        let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()))
        
        completion(timeline)
    }
    
    private func getCurrentLoggedCalories() -> CaloriesLoggedEntry {
        guard let sharedDefaults = UserDefaults(suiteName: "group.app.sculpty.SculptyApp") else {
            return CaloriesLoggedEntry(date: Date(), caloriesLogged: 0)
        }
        
        let caloriesLogged = sharedDefaults.integer(forKey: UserKeys.widgetCaloriesLogged.rawValue)
        
        return CaloriesLoggedEntry(date: Date(), caloriesLogged: caloriesLogged)
    }
}
