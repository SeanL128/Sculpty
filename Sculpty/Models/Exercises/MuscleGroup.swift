//
//  MuscleGroup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftUI

enum MuscleGroup: String, CaseIterable, Codable, Identifiable {
    case chest, back, biceps, triceps, shoulders, quads, hamstrings, glutes, calves, core, cardio, other, overall
    
    var id: String { self.rawValue }
    
    static let displayOrder: [MuscleGroup] = [
        .chest, .back, .biceps, .triceps, .shoulders, .quads,
        .hamstrings, .glutes, .calves, .core, .cardio, .other
    ]
    
    static let colorMap: [MuscleGroup: Color] = [
        .chest: .red,
        .back: .blue,
        .biceps: .green,
        .triceps: .yellow,
        .shoulders: .purple,
        .quads: .orange,
        .hamstrings: .teal,
        .glutes: .pink,
        .calves: .brown,
        .core: .cyan,
        .cardio: .white,
        .other: .gray
    ]
    
    static let colorKeyValuePairs: KeyValuePairs = [
        "Chest": Color.red,
        "Back": Color.blue,
        "Biceps": Color.green,
        "Triceps": Color.yellow,
        "Shoulders": Color.purple,
        "Quads": Color.orange,
        "Hamstrings": Color.teal,
        "Glutes": Color.pink,
        "Calves": Color.brown,
        "Core": Color.cyan,
        "Cardio": Color.white,
        "Other": Color.gray
    ]
}
