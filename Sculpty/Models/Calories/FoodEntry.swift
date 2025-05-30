//
//  FoodEntry.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/4/25.
//

import Foundation
import SwiftData

@Model
class FoodEntry: Identifiable {
    var id: UUID = UUID()
    var caloriesLog: CaloriesLog?
    
    var name: String = ""
    var calories: Double = 0
    var carbs: Double = 0
    var protein: Double = 0
    var fat: Double = 0
    
    var date: Date = Date()
    
    init(name: String = "", calories: Double = 0, carbs: Double = 0, protein: Double = 0, fat: Double = 0, date: Date = Date()) {
        self.name = name
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
        self.date = date
    }
    
    init(id: UUID, name: String = "", calories: Double = 0, carbs: Double = 0, protein: Double = 0, fat: Double = 0, date: Date = Date()) {
        self.id = id
        self.name = name
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
        self.date = date
    }
}
