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
class ExerciseLog: Identifiable {
    var id: UUID = UUID()
    var workoutLog: WorkoutLog?
    
    var index: Int = 0
    @Relationship(deleteRule: .nullify, inverse: \WorkoutExercise._exerciseLogs) var exercise: WorkoutExercise?
    var completed: Bool = false
    var start: Date = Date()
    var end: Date = Date(timeIntervalSince1970: 0)
    @Relationship(deleteRule: .cascade, inverse: \SetLog.exerciseLog) private var _setLogs: [SetLog]? = []
    var setLogs: [SetLog] {
        get { _setLogs ?? [] }
        set { _setLogs = newValue.isEmpty ? nil : newValue }
    }
    
    init(index: Int, exercise: WorkoutExercise) {
        self.index = index
        self.exercise = exercise
        
        for set in exercise.sets {
            setLogs.append(SetLog(from: set))
        }
    }
    
    func toggle() {
        completed.toggle()
        
        if completed { end = Date() } else { end = Date(timeIntervalSince1970: 0) }
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
        return setLogs.filter {
                guard let set = $0.set else { return false }
                return set.exerciseType == .weight &&
                    (set.type == .main ||
                    (includeWarmUp && set.type == .warmUp) ||
                    (includeDropSet && set.type == .dropSet) ||
                    (includeCoolDown && set.type == .coolDown))
            }
            .reduce(0) { $0 + ($1.reps ?? 0) }
    }

    func getTotalWeight(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Double {
        let targetUnit = WeightUnit(rawValue: UnitsManager.weight) ?? .lbs
        
        return setLogs.filter {
                guard let set = $0.set else { return false }
                return set.exerciseType == .weight &&
                    (set.type == .main ||
                    (includeWarmUp && set.type == .warmUp) ||
                    (includeDropSet && set.type == .dropSet) ||
                    (includeCoolDown && set.type == .coolDown))
            }
            .reduce(0) {
                $0 + (WeightUnit(rawValue: $1.unit)?.convert(($1.weight ?? 0), to: targetUnit) ?? 0)
            }
    }
    
    func getTotalTime(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Double {
        return setLogs.filter {
                guard let set = $0.set else { return false }
                return set.exerciseType == .distance &&
                    (set.type == .main ||
                    (includeWarmUp && set.type == .warmUp) ||
                    (includeDropSet && set.type == .dropSet) ||
                    (includeCoolDown && set.type == .coolDown))
            }
            .reduce(0) { $0 + ($1.time ?? 0) }
    }

    func getTotalDistance(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Double {
        let targetUnit = LongLengthUnit(rawValue: UnitsManager.longLength) ?? .mi
        
        return setLogs.filter {
                guard let set = $0.set else { return false }
                return set.exerciseType == .distance &&
                    (set.type == .main ||
                    (includeWarmUp && set.type == .warmUp) ||
                    (includeDropSet && set.type == .dropSet) ||
                    (includeCoolDown && set.type == .coolDown))
            }
            .reduce(0) {
                $0 + (LongLengthUnit(rawValue: $1.unit)?.convert(($1.distance ?? 0), to: targetUnit) ?? 0)
            }
    }
    
    func getLastFinishedSetLog() -> SetLog? {
        return setLogs
            .filter { $0.completed || $0.skipped }
            .sorted { $0.end < $1.end }
            .last
    }
    
    func getMaxOneRM() -> Double {
        return setLogs.map({ $0.getOneRM() }).max() ?? 0
    }
}
