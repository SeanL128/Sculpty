//
//  CaloriesLog.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/4/25.
//

import Foundation
import SwiftData

@Model
class CaloriesLog: Identifiable {
    var id: UUID = UUID()
    
    var date: Date = Date()
    @Relationship(deleteRule: .cascade, inverse: \FoodEntry.caloriesLog) private var _entries: [FoodEntry]? = []
    
    var entries: [FoodEntry] {
        get { _entries ?? [] }
        set { _entries = newValue.isEmpty ? nil : newValue }
    }
    
    init(date: Date = Date(), entries: [FoodEntry] = []) {
        self.date = date
        self.entries = entries
    }
    
    func getTotalCalories() -> Double {
        return entries.reduce(0) { $0 + $1.calories }
    }
    
    func getTotalCarbs() -> Double {
        return entries.reduce(0) { $0 + $1.carbs }
    }
    
    func getTotalProtein() -> Double {
        return entries.reduce(0) { $0 + $1.protein }
    }
    
    func getTotalFat() -> Double {
        return entries.reduce(0) { $0 + $1.fat }
    }
}
