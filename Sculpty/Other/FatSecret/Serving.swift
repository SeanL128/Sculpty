//
//  Serving.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/2/25.
//

import Foundation

struct Serving: Codable, Equatable {
    let calories: String?
    let carbohydrate: String?
    let fat: String?
    let protein: String?
    let serving_description: String?
    let measurement_description: String?
    let metric_serving_amount: String?
    let metric_serving_unit: String?
    
    var fullServingDescription: String {
        guard let description = serving_description else { return "Unknown serving" }
        
        if description == "g" || description == "oz" || description == "ml" {
            return description
        }
        
        if description.contains("g)") || description.hasSuffix("g") ||
           description.contains("oz)") || description.hasSuffix("oz") ||
           description.contains("ml)") || description.hasSuffix("ml") {
            return description
        }
        
        if let amount = metric_serving_amount,
           let unit = metric_serving_unit,
           let amountDouble = Double(amount) {
            return "\(description) (\(amountDouble.formatted()) \(unit))"
        }
        
        return description
    }
}
