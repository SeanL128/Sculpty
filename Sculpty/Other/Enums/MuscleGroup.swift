//
//  MuscleGroup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftUI

enum MuscleGroup: String, CaseIterable, Codable, Identifiable {
    case chest = "Chest"
    case back = "Back"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case shoulders = "Shoulders"
    case quads = "Quads"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case forearms = "Forearms"
    case calves = "Calves"
    case core = "Core"
    case cardio = "Cardio"
    case other = "Other"
    case overall = "Overall"
    
    var id: String { self.rawValue }
    
    static let displayOrder: [MuscleGroup] = [
        .chest, .back, .biceps, .triceps, .shoulders, .quads,
        .hamstrings, .glutes, .forearms, .calves, .core,
        .cardio, .other
    ]
    
    static let stringDisplayOrder: [String] = displayOrder.map { $0.rawValue }
    
    static let colorMap: [MuscleGroup: Color] = [
        .chest: .red,
        .back: .blue,
        .biceps: .green,
        .triceps: .yellow,
        .shoulders: .purple,
        .quads: .orange,
        .hamstrings: .teal,
        .glutes: .pink,
        .forearms: .indigo,
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
        "Forearms": Color.indigo,
        "Calves": Color.brown,
        "Core": Color.cyan,
        "Cardio": Color.white,
        "Other": Color.gray
    ]
}
