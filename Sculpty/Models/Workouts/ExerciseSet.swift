//
//  ExerciseSet.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftData

@Model
class ExerciseSet: Identifiable, Codable {
    @Attribute(.unique) var id = UUID()
    var workoutExercise: WorkoutExercise?
    
    var index: Int
    var reps: Int
    var weight: Double
    var unit: String
    var measurement: String
    var type: ExerciseSetType
    var rir: String
    
    init(index: Int = 0, reps: Int = UserDefaults.standard.object(forKey: UserKeys.defaultReps.rawValue) as? Int ?? 12, weight: Double = UserDefaults.standard.object(forKey: UserKeys.defaultWeight.rawValue) as? Double ?? 40, unit: String = UserDefaults.standard.object(forKey: UserKeys.defaultUnits.rawValue) as? String ?? UnitsManager.weight, measurement: String = UserDefaults.standard.object(forKey: UserKeys.defaultMeasurement.rawValue) as? String ?? "x", type: ExerciseSetType = ExerciseSetType(rawValue: UserDefaults.standard.object(forKey: UserKeys.defaultType.rawValue) as? String ?? "Main") ?? .main, rir: String = UserDefaults.standard.object(forKey: UserKeys.defaultRir.rawValue) as? String ?? "0") {
        self.index = index
        self.reps = reps
        self.weight = weight
        self.unit = unit
        self.measurement = measurement
        self.type = type
        self.rir = rir
    }
    
    func copy() -> ExerciseSet {
        return ExerciseSet(index: index, reps: reps, weight: weight, measurement: measurement, type: type, rir: rir)
    }
    
    func weight(in unit: WeightUnit) -> Double {
        return WeightUnit(rawValue: self.unit)!.convert(weight, to: unit)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, reps, weight, unit, measurement, type, rir
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        reps = try container.decode(Int.self, forKey: .reps)
        weight = try container.decode(Double.self, forKey: .weight)
        unit = try container.decode(String.self, forKey: .unit)
        measurement = try container.decode(String.self, forKey: .measurement)
        type = try container.decode(ExerciseSetType.self, forKey: .type)
        rir = try container.decode(String.self, forKey: .rir)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
        try container.encode(unit, forKey: .unit)
        try container.encode(measurement, forKey: .measurement)
        try container.encode(type, forKey: .type)
        try container.encode(rir, forKey: .rir)
    }
}

enum ExerciseSetType: String, CaseIterable, Codable, Identifiable {
    case warmUp = "Warm Up"
    case main = "Main"
    case dropSet = "Drop Set"
    case coolDown = "Cool Down"
    
    var id: String { self.rawValue }
    
    static let displayOrder: [ExerciseSetType] = [
        .warmUp, .main, .dropSet, .coolDown
    ]
}
