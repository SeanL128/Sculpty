//
//  Workout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@Model
class Workout: Identifiable, Codable {
    @Attribute(.unique) var id = UUID()
    
    var index: Int
    var name: String
    @Relationship(deleteRule: .deny, inverse: \WorkoutExercise.workout) var exercises: [WorkoutExercise]
    var notes: String
    var lastStarted: Date?
    var hidden: Bool = false
    
    init(index: Int = -1, name: String = "", exercises: [WorkoutExercise] = [], notes: String = "", lastStarted: Date? = nil, hidden: Bool = false) {
        self.index = index
        self.name = name
        self.exercises = exercises
        self.notes = notes
        self.lastStarted = lastStarted
        self.hidden = hidden
    }
    
    func started(date: Date = Date()) {
        lastStarted = date
    }
    
    func hide() {
        hidden = true
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, name, exercises, notes, lastStarted, hidden
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        name = try container.decode(String.self, forKey: .name)
        exercises = try container.decode([WorkoutExercise].self, forKey: .exercises)
        notes = try container.decode(String.self, forKey: .notes)
        lastStarted = try container.decodeIfPresent(Date.self, forKey: .lastStarted)
        hidden = try container.decode(Bool.self, forKey: .hidden)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(name, forKey: .name)
        try container.encode(exercises, forKey: .exercises)
        try container.encode(notes, forKey: .notes)
        try container.encodeIfPresent(lastStarted, forKey: .lastStarted)
        try container.encode(hidden, forKey: .hidden)
    }
}
