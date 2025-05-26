//
//  Goal.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/24/25.
//

import Foundation

enum Goal: String, CaseIterable {
    case lose = "Lose Weight"
    case maintain = "Maintain Weight"
    case gain = "Gain Weight"
    
    static let displayOrder: [Goal] = [
        .lose, .maintain, .gain
    ]
    
    static let stringDisplayOrder: [String] = displayOrder.map(\.self.rawValue)
}
