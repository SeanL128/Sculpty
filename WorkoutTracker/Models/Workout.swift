//
//  Workout.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/12/25.
//

import Foundation
import SwiftData

@Model
class Workout: Identifiable, Codable {
    @Attribute(.unique) var id = UUID()
    
    var name: String
    var exercises: [WorkoutExercise]
    var notes: String
    
    init(name: String = "Workout", exercises: [WorkoutExercise] = [], notes: String = "Notes") {
        self.name = name
        self.exercises = exercises
        self.notes = notes
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, exercises, notes
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        exercises = try container.decode([WorkoutExercise].self, forKey: .exercises)
        notes = try container.decode(String.self, forKey: .notes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(exercises, forKey: .exercises)
        try container.encode(notes, forKey: .notes)
    }
}
