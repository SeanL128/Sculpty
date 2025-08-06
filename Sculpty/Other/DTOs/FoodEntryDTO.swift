//
//  FoodEntryDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/23/25.
//

import Foundation

struct FoodEntryDTO: Identifiable, Codable {
    var id: UUID
    var fatSecretFood: FatSecretFood?
    var customFood: CustomFoodDTO?
    var servings: Double?
    var fatSecretServingOption: Serving?
    var customServingOption: CustomServing?
    var name: String
    var calories: Double
    var carbs: Double
    var protein: Double
    var fat: Double
    var date: Date
    
    init(from model: FoodEntry) {
        self.id = model.id
        self.fatSecretFood = model.fatSecretFood
        if let customFood = model.customFood {
            self.customFood = CustomFoodDTO(from: customFood)
        }
        self.servings = model.servings
        self.fatSecretServingOption = model.fatSecretServingOption
        self.customServingOption = model.customServingOption
        self.name = model.name
        self.calories = model.calories
        self.carbs = model.carbs
        self.protein = model.protein
        self.fat = model.fat
        self.date = model.date
    }
    
    func toModel() -> FoodEntry {
        let entry = FoodEntry(
            id: id,
            fatSecretFood: fatSecretFood,
            customFood: customFood?.toModel(),
            servings: servings,
            fatSecretServingOption: fatSecretServingOption,
            customServingOption: customServingOption,
            name: name,
            calories: calories,
            carbs: carbs,
            protein: protein,
            fat: fat,
            date: date
        )
        
        return entry
    }
}
