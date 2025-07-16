//
//  FatSecretFood.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/2/25.
//

import Foundation

struct FatSecretFood: Codable, Equatable, Hashable {
    let food_id: String
    let food_name: String
    let food_type: String
    let brand_name: String?
    let food_description: String?
    let food_url: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(food_id)
    }
}
