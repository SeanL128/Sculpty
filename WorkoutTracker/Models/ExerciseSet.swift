//
//  ExerciseSet.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftData

@Model
class ExerciseSet: Identifiable, Codable {
    @Attribute(.unique) var id = UUID()
    
    var index: Int
    var reps: Int
    var weight: Double
    var measurement: String
    var type: String
    var rir: String
    
    init(index: Int = 0, reps: Int = 12, weight: Double = 40, measurement: String = "x", type: String = "Main", rir: String = "0") {
        self.index = index
        self.reps = reps
        self.weight = weight
        self.measurement = measurement
        self.type = type
        self.rir = rir
    }
    
    func copy() -> ExerciseSet {
        return ExerciseSet(index: index, reps: reps, weight: weight, measurement: measurement, type: type, rir: rir)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, reps, weight, measurement, type, rir
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        reps = try container.decode(Int.self, forKey: .reps)
        weight = try container.decode(Double.self, forKey: .weight)
        measurement = try container.decode(String.self, forKey: .measurement)
        type = try container.decode(String.self, forKey: .type)
        rir = try container.decode(String.self, forKey: .rir)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(reps, forKey: .reps)
        try container.encode(weight, forKey: .weight)
        try container.encode(measurement, forKey: .measurement)
        try container.encode(type, forKey: .type)
        try container.encode(rir, forKey: .rir)
    }
}
