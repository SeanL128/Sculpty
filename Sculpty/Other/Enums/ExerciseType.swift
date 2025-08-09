//
//  ExerciseType.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/5/25.
//

import Foundation

enum ExerciseType: String, CaseIterable, Codable, Identifiable {
    case weight = "Weight"
    case distance = "Distance"
    
    var id: String { self.rawValue }
    
    static let displayOrder: [ExerciseType] = [
        .weight, .distance
    ]
    
    static let stringDisplayOrder: [String] = displayOrder.map { $0.rawValue }
}
