//
//  FoodEntryDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/23/25.
//

import Foundation

class FoodEntryDTO: Identifiable, Codable {
    var id: UUID
    
    var name: String
    var calories: Double
    var carbs: Double
    var protein: Double
    var fat: Double
    
    init(from model: FoodEntry) {
        self.id = model.id
        self.name = model.name
        self.calories = model.calories
        self.carbs = model.carbs
        self.protein = model.protein
        self.fat = model.fat
    }
}
