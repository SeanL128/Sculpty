//
//  ExerciseSet.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/31/25.
//

import Foundation
import SwiftData

@Model
class ExerciseSet: Identifiable, Codable {
    @Attribute(.unique) var id = UUID()
    var workoutExercise: WorkoutExercise?
    var index: Int
    
    var unit: String
    var type: ExerciseSetType
    var exerciseType: ExerciseType
    
    // Weight-specific
    var reps: Int?
    var weight: Double?
    var rir: String?
    
    // Distance-specific
    var time: Double?
    var distance: Double?
    var timeString: String {
        if let time = time {
            let totalSeconds = Int(time)
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60

            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
        }
        
        return ""
    }
    
    init(index: Int = 0,
         reps: Int = 12,
         weight: Double = 40,
         unit: String = UnitsManager.weight,
         type: ExerciseSetType = .main,
         rir: String = "0") {
        self.index = index
        self.unit = unit
        self.type = type
        exerciseType = .weight
        
        self.reps = reps
        self.weight = weight
        self.rir = rir
    }
    
    init(index: Int = 0,
         time: Double = 300,
         distance: Double = 1,
         unit: String = UnitsManager.longLength,
         type: ExerciseSetType = .main) {
        self.index = index
        self.unit = unit
        self.type = type
        exerciseType = .distance
        
        self.time = time
        self.distance = distance
    }
    
    init(index: Int = 0, type: ExerciseType) {
        self.index = index
        unit = ""
        self.type = .main
        exerciseType = type
        
        if type == .weight {
            unit = UnitsManager.weight
            
            reps = 12
            weight = 40
            rir = "0"
        } else if type == .distance {
            unit = UnitsManager.longLength
            
            time = 300
            distance = 1
        }
    }
    
    func copy() -> ExerciseSet {
        return ExerciseSet(from: self)
    }
    
    private init(from set: ExerciseSet) {
        index = set.index
        unit = set.unit
        type = set.type
        exerciseType = set.exerciseType
        
        if set.exerciseType == .weight,
           let reps = set.reps,
           let weight = set.weight,
           let rir = set.rir {
            self.reps = reps
            self.weight = weight
            self.rir = rir
        }
        
        if set.exerciseType == .distance,
           let time = set.time,
           let distance = set.distance {
            self.time = time
            self.distance = distance
        }
    }
    
    func weight(in unit: WeightUnit) -> Double {
        if let weight = self.weight {
            return WeightUnit(rawValue: self.unit)!.convert(weight, to: unit)
        }
        
        return 0
    }
    
    func distance(in unit: LongLengthUnit) -> Double {
        if let distance = self.distance {
            return LongLengthUnit(rawValue: self.unit)!.convert(distance, to: unit)
        }
        
        return 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, unit, type, exerciseType, reps, weight, rir, time, distance
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        unit = try container.decode(String.self, forKey: .unit)
        type = try container.decode(ExerciseSetType.self, forKey: .type)
        exerciseType = try container.decode(ExerciseType.self, forKey: .exerciseType)
        
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        rir = try container.decodeIfPresent(String.self, forKey: .rir)
        
        time = try container.decodeIfPresent(Double.self, forKey: .time)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(unit, forKey: .unit)
        try container.encode(type, forKey: .type)
        try container.encode(exerciseType, forKey: .exerciseType)
        
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
        try container.encode(rir, forKey: .rir)
        
        try container.encode(time, forKey: .time)
        try container.encode(distance, forKey: .distance)
    }
}
