//
//  WorkoutExercise.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftData

@Model
class WorkoutExercise: Identifiable, Codable {
    @Attribute(.unique) var id = UUID()
    var workout: Workout?
    
    var index: Int
    @Relationship(deleteRule: .deny) var exercise: Exercise?
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
    
    func addSet() {
        sets = sets.sorted { $0.index < $1.index }
        
        let index = (sets.map { $0.index }.max() ?? -1) + 1
        let set = ExerciseSet(index: index, type: exercise?.type ?? .weight)
        sets.append(set)
    }
    
    func deleteSet(at index: Int) {
        guard sets.indices.contains(index) else { return }
        
        let i = sets[index].index
        sets.remove(at: index)
        
        for set in sets {
            if set.index > i {
                set.index = set.index - 1
            }
        }
    }
    
    func deleteSet(index: Int) {
        let i = sets.firstIndex(where: { $0.index == index }) ?? -1
        
        if i != -1 {
            sets.remove(at: i)
            
            for set in sets {
                if set.index > index {
                    set.index = set.index - 1
                }
            }
        }
    }
    
    func deleteSet(set: ExerciseSet) {
        sets = sets.sorted { $0.index < $1.index }
        
        let i = sets.firstIndex(where: { $0.id == set.id }) ?? -1
        
        if i != -1 {
            deleteSet(at: i)
        }
    }
    
    func copy() -> WorkoutExercise {
        return WorkoutExercise(from: self)
    }
    
    private init (from e: WorkoutExercise) {
        index = e.index
        exercise = e.exercise
        sets = []
        restTime = e.restTime
        specNotes = e.specNotes
        tempo = e.tempo
        
        for s in e.sets.sorted(by: { $0.index < $1.index }) {
            sets.append(s.copy())
        }
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
