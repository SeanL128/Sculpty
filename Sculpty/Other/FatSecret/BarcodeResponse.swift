//
//  BarcodeResponse.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/14/25.
//

import Foundation

struct BarcodeResponse: Codable {
    let food_id: String
    let food_name: String
    let food_type: String
    let brand_name: String?
    let food_description: String?
    let food_url: String?
    let detail: FoodDetail?
    
    func toFatSecretFood() -> FatSecretFood {
        return FatSecretFood(
            food_id: food_id,
            food_name: food_name,
            food_type: food_type,
            brand_name: brand_name,
            food_description: food_description,
            food_url: food_url
        )
    }
}
