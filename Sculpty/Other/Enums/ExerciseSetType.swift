//
//  ExerciseSetType.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/24/25.
//

import Foundation

enum ExerciseSetType: String, CaseIterable, Codable, Identifiable {
    case warmUp = "Warm Up"
    case main = "Main"
    case dropSet = "Drop Set"
    case coolDown = "Cool Down"
    
    var id: String { self.rawValue }
    
    static let displayOrder: [ExerciseSetType] = [
        .warmUp, .main, .dropSet, .coolDown
    ]
    
    static let stringDisplayOrder: [String] = displayOrder.map(\.self.rawValue)
}
