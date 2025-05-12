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
        id = model.id
        date = model.date
        entries = model.entries.map { FoodEntryDTO(from: $0) }
    }
}
