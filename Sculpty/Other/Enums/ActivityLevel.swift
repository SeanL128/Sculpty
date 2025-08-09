//
//  ActivityLevel.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/24/25.
//

import Foundation

enum ActivityLevel: String, CaseIterable {
    case sedentary = "Sedentary (little or no exercise)"
    case light = "Light (1-3 days/week)"
    case moderate = "Moderate (3-5 days/week)"
    case active = "Active (6-7 days/week)"
    case veryActive = "Very Active (athlete, intense training)"
    
    static let displayOrder: [ActivityLevel] = [
        .sedentary, .light, .moderate, .active, .veryActive
    ]
    
    static let stringDisplayOrder: [String] = displayOrder.map { $0.rawValue }
}
