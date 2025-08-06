//
//  CustomFoodDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import Foundation

struct CustomFoodDTO: Identifiable, Codable {
    var id: UUID
    var name: String
    var servingOptions: [CustomServing] = []
    var hidden: Bool = false
    
    init(from model: CustomFood) {
        self.id = model.id
        self.name = model.name
        self.servingOptions = model.servingOptions
        self.hidden = model.hidden
    }
    
    func toModel() -> CustomFood {
        let food = CustomFood(
            id: id,
            name: name,
            servingOptions: servingOptions,
            hidden: hidden
        )
        
        return food
    }
}
