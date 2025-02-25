//
//  Appearance.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/8/25.
//

import Foundation

enum Appearance: String, CaseIterable, Identifiable {
    case automatic = "Automatic", dark = "Dark", light = "Light"
    
    var id: String { self.rawValue }
    
    static let displayOrder: [Appearance] = [
        .automatic, .dark, .light
    ]
}
