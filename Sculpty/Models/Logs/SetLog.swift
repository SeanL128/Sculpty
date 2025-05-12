//
//  SetLog.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/5/25.
//

import Foundation
import SwiftData

@Model
class SetLog: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    var exerciseLog: ExerciseLog?
    @Relationship(deleteRule: .nullify) var set: ExerciseSet?
    var index: Int
    
    var completed: Bool
    var skipped: Bool
    var start: Date
    var end: Date
    
    var unit: String
    
    // Weight-specific
    var reps: Int?
    var weight: Double?
    var measurement: String?
    
    // Distance-specific
    var time: Double?
    var distance: Double?
    
    init(index: Int,
         set: ExerciseSet,
         unit: String = UnitsManager.weight,
         measurement: String) {
        self.index = index
        self.set = set
        completed = false
        skipped = false
        start = Date()
        end = Date(timeIntervalSince1970: 0)
        self.unit = unit
        
        reps = 0
        weight = 0
        self.measurement = measurement
    }
    
    init(index: Int,
         set: ExerciseSet,
         unit: String = UnitsManager.longLength) {
        self.index = index
        self.set = set
        completed = false
        skipped = false
        start = Date()
        end = Date(timeIntervalSince1970: 0)
        self.unit = unit
        
        if set.exerciseType == .weight,
           let measurement = set.measurement {
            reps = 0
            weight = 0
            self.measurement = measurement
        }
        else if set.exerciseType == .distance {
            time = 0
            distance = 0
        }
    }
    
    init(from set: ExerciseSet) {
        index = set.index
        self.set = set
        completed = false
        skipped = false
        start = Date()
        end = Date(timeIntervalSince1970: 0)
        unit = set.unit
        
        if set.exerciseType == .weight,
           let measurement = set.measurement {
            reps = 0
            weight = 0
            self.measurement = measurement
        }
        else if set.exerciseType == .distance {
            time = 0
            distance = 0
        }
    }
    
    func finish(reps: Int, weight: Double, measurement: String) {
        completed = true
        end = Date()
        
        self.reps = reps
        self.weight = weight * Double(reps)
        self.measurement = measurement
    }
    
    func finish(time: Double, distance: Double) {
        completed = true
        end = Date()
        
        self.time = time
        self.distance = distance
    }
    
    func unfinish() {
        completed = false
        end = Date(timeIntervalSince1970: 0)
        
        if reps != nil && weight != nil {
            reps = 0
            weight = 0
        } else if time != nil && distance != nil {
            time = 0
            distance = 0
        }
    }
    
    func skip() {
        skipped = true
        end = Date()
        
        if reps != nil && weight != nil {
            reps = 0
            weight = 0
        } else if time != nil && distance != nil {
            time = 0
            distance = 0
        }
    }
    
    func unskip() {
        skipped = false
        end = Date(timeIntervalSince1970: 0)
        
        if reps != nil && weight != nil {
            reps = 0
            weight = 0
        } else if time != nil && distance != nil {
            time = 0
            distance = 0
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, completed, skipped, start, end, unit, reps, weight, measurement, time, distance
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        completed = try container.decode(Bool.self, forKey: .completed)
        skipped = try container.decode(Bool.self, forKey: .skipped)
        start = try container.decode(Date.self, forKey: .start)
        end = try container.decode(Date.self, forKey: .end)
        unit = try container.decode(String.self, forKey: .unit)
        
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        measurement = try container.decodeIfPresent(String.self, forKey: .measurement)
        
        time = try container.decodeIfPresent(Double.self, forKey: .time)
        distance = try container.decodeIfPresent(Double.self, forKey: .distance)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(completed, forKey: .completed)
        try container.encode(skipped, forKey: .skipped)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(unit, forKey: .unit)
        
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
        try container.encode(measurement, forKey: .measurement)
        
        try container.encode(time, forKey: .time)
        try container.encode(distance, forKey: .distance)
    }
}
