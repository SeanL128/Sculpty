//
//  SetLog.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftData

@Model
class SetLog: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    
    var index: Int
    var completed: Bool
    var skipped: Bool
    var start: Double
    var end: Double
    
    var reps: Int
    var weight: Double
    
    init(index: Int) {
        self.index = index
        completed = false
        skipped = false
        start = Date().timeIntervalSince1970.rounded()
        end = 0
        weight = 0
        reps = 0
    }
    
    func finish(weight: Double = 0, reps: Int = 0) {
        completed = true
        end = Date().timeIntervalSince1970.rounded()
        
        self.weight = weight * Double(reps)
        self.reps = reps
    }
    
    func unfinish() {
        completed = false
        end = 0
        
        weight = 0
        reps = 0
    }
    
    func skip() {
        skipped = true
        end = Date().timeIntervalSince1970.rounded()
        
        weight = 0
        reps = 0
    }
    
    func unskip() {
        skipped = false
        end = 0
        
        weight = 0
        reps = 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, completed, skipped, start, end, weight, reps
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        completed = try container.decode(Bool.self, forKey: .completed)
        skipped = try container.decode(Bool.self, forKey: .skipped)
        start = try container.decode(Double.self, forKey: .start)
        end = try container.decode(Double.self, forKey: .end)
        reps = try container.decode(Int.self, forKey: .reps)
        weight = try container.decode(Double.self, forKey: .weight)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(completed, forKey: .completed)
        try container.encode(skipped, forKey: .skipped)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(weight, forKey: .weight)
        try container.encode(reps, forKey: .reps)
    }
}
