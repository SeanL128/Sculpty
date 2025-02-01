//
//  ExerciseLog.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftData

@Model
class ExerciseLog: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    var workoutLog: WorkoutLog?
    
    var index: Int
    var exercise: WorkoutExercise
    var completed: Bool
    var start: Double
    var end: Double
    @Relationship(deleteRule: .cascade, inverse: \SetLog.exerciseLog) var setLogs: [SetLog] = []
    
    init(index: Int, exercise: WorkoutExercise) {
        self.index = index
        self.exercise = exercise
        completed = false
        start = Date().timeIntervalSince1970.rounded()
        end = 0
        
        for set in exercise.sets {
            setLogs.append(SetLog(index: set.index))
        }
    }
    
    
    func toggle() {
        completed.toggle()
        
        if completed { end = Date().timeIntervalSince1970.rounded() }
        else { end = 0 }
    }
    
    func finish() {
        completed = true
        end = Date().timeIntervalSince1970.rounded()
    }
    
    func unfinish() {
        completed = false
        end = 0
    }
    
    
    func getTotalReps() -> Int {
        var reps: Int = 0
        
        for setLog in setLogs {
            reps += setLog.reps
        }
        
        return reps
    }
    
    func getTotalWeight() -> Double {
        var weight: Double = 0
        
        for setLog in setLogs {
            weight += setLog.weight
        }
        
        return weight
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, exercise, completed, start, end, setLogs
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        exercise = try container.decode(WorkoutExercise.self, forKey: .exercise)
        completed = try container.decode(Bool.self, forKey: .completed)
        start = try container.decode(Double.self, forKey: .start)
        end = try container.decode(Double.self, forKey: .end)
        setLogs = try container.decode([SetLog].self, forKey: .setLogs)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(exercise, forKey: .exercise)
        try container.encode(completed, forKey: .completed)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(setLogs, forKey: .setLogs)
    }
}
