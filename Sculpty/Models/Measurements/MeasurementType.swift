//
//  MeasurementType.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/11/25.
//

import Foundation

enum MeasurementType: String, CaseIterable, Codable, Identifiable {
    case weight = "Weight"
    case height = "Height"
    case bodyFat = "Body Fat Percentage"
    case neck = "Neck"
    case shoulders = "Shoulders"
    case chest = "Chest"
    case upperArmLeft = "Upper Arm (Left)"
    case upperArmRight = "Upper Arm (Right)"
    case forearmLeft = "Forearm (Left)"
    case forearmRight = "Forearm (Right)"
    case waist = "Waist"
    case hips = "Hips"
    case thighLeft = "Thigh (Left)"
    case thighRight = "Thigh (Right)"
    case calfLeft = "Calf (Left)"
    case calfRight = "Calf (Right)"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    static let displayOrder: [MeasurementType] = [
        .weight, .height, .bodyFat, .neck, .shoulders, .chest, .upperArmLeft, .upperArmRight,
        .forearmLeft, .forearmRight, .waist, .hips, .thighLeft, .thighRight, .calfLeft, .calfRight
    ]
}
