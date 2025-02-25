//
//  ScheduleDay.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/17/25.
//

import Foundation
import SwiftData

@Model
class ScheduleDay: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    
    var index: Int
    var workouts: [Workout]
    
    var restDay: Bool
    
    init(index: Int, workouts: [Workout], restDay: Bool = false) {
        self.index = index
        self.workouts = workouts
        self.restDay = restDay
    }
    
    func addWorkout(_ workout: Workout) {
        self.workouts.append(workout)
    }
    
    func removeWorkout(_ workout: Workout) {
        let index = self.workouts.firstIndex(of: workout)!
        
        self.removeWorkout(at: index)
    }
    
    func removeWorkout(at index: Int) {
        self.workouts.remove(at: index)
    }
    
    func copy() -> ScheduleDay {
        return ScheduleDay(index: self.index, workouts: self.workouts, restDay: self.restDay)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, workouts, restDay
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        workouts = try container.decode([Workout].self, forKey: .workouts)
        restDay = try container.decode(Bool.self, forKey: .restDay)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(workouts, forKey: .workouts)
        try container.encode(restDay, forKey: .restDay)
    }
}
