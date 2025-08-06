//
//  CaloriesEntry.swift
//  SculptyWidgetsExtension
//
//  Created by Sean Lindsay on 8/5/25.
//

import WidgetKit

struct CaloriesEntry: TimelineEntry {
    let date: Date
    let totalCalories: Int
    let targetCalories: Int
    let carbs: Int
    let protein: Int
    let fat: Int
    
    var remainingCalories: Int {
        max(0, targetCalories - totalCalories)
    }
}
