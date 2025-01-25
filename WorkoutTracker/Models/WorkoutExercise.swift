//
//  WorkoutExercise.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftData

@Model
class WorkoutExercise: Identifiable, Codable {
    @Attribute(.unique) var id = UUID()
    
    var index: Int
    var exercise: Exercise?
    var sets: [ExerciseSet]
    var restTime: TimeInterval
    var specNotes: String
    var tempo: String
    
    init(index: Int = 0, exercise: Exercise? = nil, sets: [ExerciseSet] = [], restTime: TimeInterval = 180, specNotes: String = "", tempo: String = "XXXX") {
        self.index = index
        self.exercise = exercise
        self.sets = sets
        self.restTime = restTime
        self.specNotes = specNotes
        self.tempo = tempo
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, exercise, sets, restTime, specNotes, tempo
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        exercise = try container.decode(Exercise.self, forKey: .exercise)
        sets = try container.decode([ExerciseSet].self, forKey: .sets)
        restTime = try container.decode(TimeInterval.self, forKey: .restTime)
        specNotes = try container.decode(String.self, forKey: .specNotes)
        tempo = try container.decode(String.self, forKey: .tempo)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(exercise, forKey: .exercise)
        try container.encode(sets, forKey: .sets)
        try container.encode(restTime, forKey: .restTime)
        try container.encode(specNotes, forKey: .specNotes)
        try container.encode(tempo, forKey: .tempo)
    }
}
