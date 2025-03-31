//
//  SetLog.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftData

@Model
class SetLog: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    var exerciseLog: ExerciseLog?
    @Relationship(deleteRule: .nullify) var set: BaseSet?
    
    var index: Int
    var completed: Bool
    var skipped: Bool
    var start: Date
    var end: Date
    
    var reps: Int = 0
    var weight: Double = 0
    var time: Double = 0
    var distance: Double = 0
    var unit: String
    var measurement: String
    
    init(index: Int, set: BaseSet, unit: String = "lbs", measurement: String = "x") {
        self.index = index
        self.set = set
        completed = false
        skipped = false
        start = Date()
        end = Date(timeIntervalSince1970: 0)
        self.unit = unit
        self.measurement = measurement
    }
    
    func finish(reps: Int = 0, weight: Double = 0, measurement: String = "x") {
        completed = true
        end = Date()
        
        if set is ExerciseSet {
            self.reps = reps
            self.weight = weight * Double(reps)
            self.measurement = measurement
            
            self.time = 0
            self.distance = 0
        }
    }
    
    func finish(time: Double = 0, distance: Double = 0) {
        completed = true
        end = Date()
        
        if set is DistanceSet {
            self.time = time
            self.distance = distance
            
            self.reps = 0
            self.weight = 0
        }
    }
    
    func unfinish() {
        completed = false
        end = Date(timeIntervalSince1970: 0)
        
        reps = 0
        weight = 0
        time = 0
        distance = 0
    }
    
    func skip() {
        skipped = true
        end = Date()
        
        reps = 0
        weight = 0
        time = 0
        distance = 0
    }
    
    func unskip() {
        skipped = false
        end = Date(timeIntervalSince1970: 0)
        
        reps = 0
        weight = 0
        time = 0
        distance = 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, completed, skipped, start, end, reps, weight, time, distance, unit, measurement
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        completed = try container.decode(Bool.self, forKey: .completed)
        skipped = try container.decode(Bool.self, forKey: .skipped)
        start = try container.decode(Date.self, forKey: .start)
        end = try container.decode(Date.self, forKey: .end)
        reps = try container.decode(Int.self, forKey: .reps)
        weight = try container.decode(Double.self, forKey: .weight)
        time = try container.decode(Double.self, forKey: .time)
        distance = try container.decode(Double.self, forKey: .distance)
        unit = try container.decode(String.self, forKey: .unit)
        measurement = try container.decode(String.self, forKey: .measurement)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(completed, forKey: .completed)
        try container.encode(skipped, forKey: .skipped)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
        try container.encode(time, forKey: .time)
        try container.encode(distance, forKey: .distance)
        try container.encode(unit, forKey: .unit)
        try container.encode(measurement, forKey: .measurement)
    }
}
