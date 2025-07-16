//
//  Appearance.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/16/25.
//

import Foundation

enum Appearance: String, CaseIterable, Identifiable, Codable {
    case automatic = "Automatic"
    case dark = "Dark"
    case light = "Light"
    
    var id: String { self.rawValue }
    
    static let displayOrder: [Appearance] = [
        .automatic, .dark, .light
    ]
}
