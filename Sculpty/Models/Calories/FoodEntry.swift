//
//  FoodEntry.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/4/25.
//

import Foundation
import SwiftData

@Model
class FoodEntry: Identifiable, Codable {
    @Attribute(.unique) public var id: UUID = UUID()
    var caloriesLog: CaloriesLog?
    
    var name: String
    var calories: Double
    var carbs: Double
    var protein: Double
    var fat: Double
    
    init(name: String, calories: Double, carbs: Double = 0, protein: Double = 0, fat: Double = 0) {
        self.name = name
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
    }
    
    enum CodingKeys: String, CodingKey {
        case id, caloriesLog, name, calories, carbs, protein, fat
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        caloriesLog = try container.decode(CaloriesLog.self, forKey: .caloriesLog)
        name = try container.decode(String.self, forKey: .name)
        calories = try container.decode(Double.self, forKey: .calories)
        carbs = try container.decode(Double.self, forKey: .carbs)
        protein = try container.decode(Double.self, forKey: .protein)
        fat = try container.decode(Double.self, forKey: .fat)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(caloriesLog, forKey: .caloriesLog)
        try container.encode(name, forKey: .name)
        try container.encode(calories, forKey: .calories)
        try container.encode(carbs, forKey: .carbs)
        try container.encode(protein, forKey: .protein)
        try container.encode(fat, forKey: .fat)
    }
}
