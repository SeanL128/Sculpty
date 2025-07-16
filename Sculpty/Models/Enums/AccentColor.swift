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
    case cyan = "Cyan"
    case teal = "Teal"
    case green = "Green"
    case orange = "Orange"
    case magenta = "Magenta"
    case indigo = "Indigo"
    
    var id: String { self.rawValue }
    
    static let displayOrder: [AccentColor] = [
        .blue, .purple, .cyan, .teal, .green, .orange, .magenta, .indigo
    ]
    
    static let stringDisplayOrder: [String] = displayOrder.map(\.self.rawValue)
    
    static let colorMap: [AccentColor: String] = [
        .blue: "#2B7EFF",
        .purple: "#6B5EFF",
        .cyan: "#00B8D4",
        .teal: "#00A693",
        .green: "#2DD653",
        .orange: "#FF6B35",
        .magenta: "#D946EF",
        .indigo: "#5856D6"
    ]
    
    static func fromHex(_ hex: String) -> AccentColor? {
        return colorMap.first { $0.value.lowercased() == hex.lowercased() }?.key
    }
}
