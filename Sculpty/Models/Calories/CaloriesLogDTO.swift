//
//  CaloriesLogDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/23/25.
//

import Foundation

class CaloriesLogDTO: Identifiable, Codable {
    var id: UUID
    
    var date: Date
    var entries: [FoodEntryDTO]
    
    init(from model: CaloriesLog) {
        self.id = model.id
        self.date = model.date
        self.entries = model.entries.map { FoodEntryDTO(from: $0) }
    }
}
