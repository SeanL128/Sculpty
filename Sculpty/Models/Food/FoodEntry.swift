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
    
    var fatSecretFood: FatSecretFood?
    var customFood: CustomFood?
    
    var servings: Double?
    var fatSecretServingOption: Serving?
    var customServingOption: CustomServing?
    
    var name: String = ""
    var calories: Double = 0
    var carbs: Double = 0
    var protein: Double = 0
    var fat: Double = 0
    
    var date: Date = Date()
    
    var type: FoodEntryType {
        if fatSecretFood != nil {
            return .fatSecret
        } else if customFood != nil {
            return .custom
        } else {
            return .oneshot
        }
    }
    
    init(
        caloriesLog: CaloriesLog? = nil,
        fatSecretFood: FatSecretFood? = nil,
        customFood: CustomFood? = nil,
        servings: Double? = nil,
        fatSecretServingOption: Serving? = nil,
        customServingOption: CustomServing? = nil,
        name: String = "",
        calories: Double = 0,
        carbs: Double = 0,
        protein: Double = 0,
        fat: Double = 0,
        date: Date = Date()
    ) {
        self.caloriesLog = caloriesLog
        
        self.fatSecretFood = fatSecretFood
        self.customFood = customFood
        
        self.servings = servings
        self.fatSecretServingOption = fatSecretServingOption
        self.customServingOption = customServingOption
        
        self.name = name
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
        self.date = date
    }
    
    init(
        id: UUID,
        caloriesLog: CaloriesLog? = nil,
        fatSecretFood: FatSecretFood? = nil,
        customFood: CustomFood? = nil,
        servings: Double? = nil,
        fatSecretServingOption: Serving? = nil,
        customServingOption: CustomServing? = nil,
        name: String = "",
        calories: Double = 0,
        carbs: Double = 0,
        protein: Double = 0,
        fat: Double = 0,
        date: Date = Date()
    ) {
        self.id = id
        
        self.caloriesLog = caloriesLog
        
        self.fatSecretFood = fatSecretFood
        self.customFood = customFood
        
        self.servings = servings
        self.fatSecretServingOption = fatSecretServingOption
        self.customServingOption = customServingOption
        
        self.name = name
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
        self.date = date
    }
}
