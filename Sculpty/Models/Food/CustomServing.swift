//
//  CustomServing.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import Foundation

struct CustomServing: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    
    var index: Int = -1
    
    var desc: String = ""
    
    var calories: Double = 0
    var carbs: Double = 0
    var protein: Double = 0
    var fat: Double = 0
    
    init(
        id: UUID = UUID(),
        index: Int = -1,
        desc: String = "",
        calories: Double = 0,
        carbs: Double = 0,
        protein: Double = 0,
        fat: Double = 0
    ) {
        self.id = id
        
        self.index = index
        
        self.desc = desc
        
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, desc, description, calories, carbs, protein, fat
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        
        if let descValue = try container.decodeIfPresent(String.self, forKey: .desc) {
            desc = descValue
        } else {
            desc = try container.decode(String.self, forKey: .description)
        }
        
        calories = try container.decode(Double.self, forKey: .calories)
        carbs = try container.decode(Double.self, forKey: .carbs)
        protein = try container.decode(Double.self, forKey: .protein)
        fat = try container.decode(Double.self, forKey: .fat)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(desc, forKey: .desc)
        try container.encode(calories, forKey: .calories)
        try container.encode(carbs, forKey: .carbs)
        try container.encode(protein, forKey: .protein)
        try container.encode(fat, forKey: .fat)
    }
}
