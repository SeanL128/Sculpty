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
        id = model.id
        name = model.name
        calories = model.calories
        carbs = model.carbs
        protein = model.protein
        fat = model.fat
    }
}
