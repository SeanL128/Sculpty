//
//  AccentColor.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/8/25.
//

import Foundation

enum AccentColor: String, CaseIterable, Identifiable {
    case red = "Red", orange = "Orange", yellow = "Yellow", green = "Green", blue = "Blue", teal = "Teal", purple = "Purple", pink = "Pink"
    
    var id: String { self.rawValue }
    
    static let displayOrder: [AccentColor] = [
        .red, .orange, .yellow, .green, .blue, .teal, .purple, .pink
    ]
    
    static let colorMap: [AccentColor: String] = [
        .red: "#C50A2B",
        .orange: "#E67E22",
        .yellow: "#F1C40F",
        .green: "#2ECC71",
        .blue: "#2980B9",
        .teal: "#1ABC9C",
        .purple: "#8E44AD",
        .pink: "#D63384"
    ]
    
    static func fromHex(_ hex: String) -> AccentColor? {
        return colorMap.first { $0.value.lowercased() == hex.lowercased() }?.key
    }
}
