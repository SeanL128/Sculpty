//
//  AccentColor.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/16/25.
//

import Foundation

enum AccentColor: String, CaseIterable, Identifiable {
    case blue = "Blue"
    case purple = "Purple"
    case green = "Green"
    
    var id: String { self.rawValue }
    
    static let displayOrder: [AccentColor] = [
        .blue, .purple, .green
    ]
    
    static let stringDisplayOrder: [String] = displayOrder.map(\.self.rawValue)
    
    static let colorMap: [AccentColor: String] = [
        .blue: "#2563EB",
        .purple: "#7C3AED",
        .green: "#059669"
    ]
    
    static func fromHex(_ hex: String) -> AccentColor? {
        return colorMap.first { $0.value.lowercased() == hex.lowercased() }?.key
    }
}
