//
//  CaloriesLog.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/4/25.
//

import Foundation
import SwiftData

@Model
class CaloriesLog: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    
    var date: Date
    @Relationship(deleteRule: .cascade, inverse: \FoodEntry.caloriesLog) var entries: [FoodEntry] = []
    
    init(date: Date = Date(), entries: [FoodEntry] = []) {
        self.id = UUID()
        self.date = date
        self.entries = entries
    }
    
    init(from dto: CaloriesLogDTO) {
        self.id = dto.id
        self.date = dto.date
        
        var entries: [FoodEntry] = []
        for entry in dto.entries {
            entries.append(FoodEntry(id: entry.id, name: entry.name, calories: entry.calories, carbs: entry.carbs, protein: entry.protein, fat: entry.fat))
        }
        
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
    
    enum CodingKeys: String, CodingKey {
        case id, entries, date
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        entries = try container.decode([FoodEntry].self, forKey: .entries)
        date = try container.decode(Date.self, forKey: .date)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(entries, forKey: .entries)
        try container.encode(date, forKey: .date)
    }
}
