//
//  ExerciseLog.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class ExerciseLog: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    var workoutLog: WorkoutLog?
    
    var index: Int
    var exercise: WorkoutExercise
    var completed: Bool
    var start: Date
    var end: Date
    @Relationship(deleteRule: .cascade, inverse: \SetLog.exerciseLog) var setLogs: [SetLog] = []
    
    init(index: Int, exercise: WorkoutExercise) {
        self.index = index
        self.exercise = exercise
        completed = false
        start = Date()
        end = Date(timeIntervalSince1970: 0)
        
        for set in exercise.sets {
            setLogs.append(SetLog(index: set.index, set: set, unit: set.unit, measurement: set.measurement))
        }
    }
    
    
    func toggle() {
        completed.toggle()
        
        if completed { end = Date() }
        else { end = Date(timeIntervalSince1970: 0) }
    }
    
    func finish() {
        completed = true
        end = Date()
    }
    
    func unfinish() {
        completed = false
        end = Date(timeIntervalSince1970: 0)
    }
    
    
    func getTotalReps(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Int {
        return setLogs.filter({
            guard let set = $0.set as? ExerciseSet else { return false }
            
            return set.type == .main ||
                   (includeWarmUp && set.type == .warmUp) ||
                   (includeDropSet && set.type == .dropSet) ||
                   (includeCoolDown && set.type == .coolDown)
        }).reduce(0) { $0 + $1.reps}
    }
    
    func getTotalWeight(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Double {
        let targetUnit = WeightUnit(rawValue: UnitsManager.weight) ?? .lbs
        return setLogs.filter({
            guard let set = $0.set as? ExerciseSet else { return false }
            
            return set.type == .main ||
                   (includeWarmUp && set.type == .warmUp) ||
                   (includeDropSet && set.type == .dropSet) ||
                   (includeCoolDown && set.type == .coolDown)
        }).reduce(0) { $0 + WeightUnit(rawValue: $1.unit)!.convert($1.weight, to: targetUnit) }
    }
    
    func getTotalTime(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Double {
        return setLogs.filter({
            guard let set = $0.set as? DistanceSet else { return false }
            
            return set.type == .main ||
                   (includeWarmUp && set.type == .warmUp) ||
                   (includeDropSet && set.type == .dropSet) ||
                   (includeCoolDown && set.type == .coolDown)
        }).reduce(0) { $0 + $1.time}
    }
    
    func getTotalDistance(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Double {
        let targetUnit = LongLengthUnit(rawValue: UnitsManager.longLength) ?? .mi
        return setLogs.filter({
            guard let set = $0.set as? DistanceSet else { return false }
            
            return set.type == .main ||
                   (includeWarmUp && set.type == .warmUp) ||
                   (includeDropSet && set.type == .dropSet) ||
                   (includeCoolDown && set.type == .coolDown)
        }).reduce(0) { $0 + LongLengthUnit(rawValue: $1.unit)!.convert($1.distance, to: targetUnit) }
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
        start = try container.decode(Date.self, forKey: .start)
        end = try container.decode(Date.self, forKey: .end)
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
