//
//  FoodDetail.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/2/25.
//

import Foundation

struct FoodDetail: Codable {
    let food_id: String
    let food_name: String
    let food_type: String
    let brand_name: String?
    let servings: ServingCollection?
}
