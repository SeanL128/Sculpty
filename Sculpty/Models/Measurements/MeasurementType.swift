//
//  MeasurementType.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/11/25.
//

import Foundation

enum MeasurementType: String, CaseIterable, Codable, Identifiable {
    case weight = "Weight", height = "Height", bodyFat = "Body Fat Percentage", neck = "Neck", shoulders = "Shoulders", chest = "Chest",
         upperArmLeft = "Upper Arm (Left)", upperArmRight = "Upper Arm (Right)", forearmLeft = "Forearm (Left)", forearmRight = "Forearm (Right)",
         waist = "Waist", hips = "Hips", thighLeft = "Thigh (Left)", thighRight = "Thigh (Right)", calfLeft = "Calf (Left)", calfRight = "Calf (Right)",
         other = "Other"
    
    var id: String { self.rawValue }
    
    static let displayOrder: [MeasurementType] = [
        .weight, .height, .bodyFat, .neck, .shoulders, .chest, .upperArmLeft, .upperArmRight,
        .forearmLeft, .forearmRight, .waist, .hips, .thighLeft, .thighRight, .calfLeft, .calfRight
    ]
}
