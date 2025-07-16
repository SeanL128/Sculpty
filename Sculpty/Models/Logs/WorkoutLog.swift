//
//  WorkoutLog.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftData

@Model
class WorkoutLog: Identifiable {
    var id: UUID = UUID()
    
    @Relationship(deleteRule: .nullify, inverse: \Workout._workoutLogs) var workout: Workout?
    var started: Bool = false
    var completed: Bool = false
    var start: Date = Date()
    var end: Date = Date(timeIntervalSince1970: 0)
    @Relationship(deleteRule: .cascade, inverse: \ExerciseLog.workoutLog) private var _exerciseLogs: [ExerciseLog]? = []
    var exerciseLogs: [ExerciseLog] {
        get { _exerciseLogs ?? [] }
        set { _exerciseLogs = newValue.isEmpty ? nil : newValue }
    }
    
    init(
        workout: Workout,
        started: Bool = false,
        completed: Bool = false,
        start: Date = Date(),
        end: Date = Date(timeIntervalSince1970: 0),
        exerciseLogs: [ExerciseLog]? = nil
    ) {
        self.workout = workout
        self.started = started
        self.completed = completed
        self.start = start
        self.end = end
        
        if let exerciseLogs = exerciseLogs {
            self.exerciseLogs = exerciseLogs
        } else {
            for exercise in workout.exercises {
                self.exerciseLogs.append(ExerciseLog(index: exercise.index, exercise: exercise))
            }
        }
        
        workout.started(date: start)
    }
    
    func updateWorkoutLog() {
        for exercise in workout?.exercises ?? [] where exerciseLogs.firstIndex(where: { $0.exercise?.id == exercise.id }) == -1 { // swiftlint:disable:this line_length
            exerciseLogs.append(ExerciseLog(index: exercise.index, exercise: exercise))
        }
        
        for exerciseLog in exerciseLogs where workout?.exercises.firstIndex(where: { $0.id == exerciseLog.exercise?.id }) == -1 { // swiftlint:disable:this line_length
            exerciseLogs.remove(at: exerciseLogs.firstIndex(of: exerciseLog)!) // swiftlint:disable:this line_length force_unwrapping
        }
    }
    
    func startWorkout() {
        start = Date()
        started = true
    }
    
    func finishWorkout(date: Date = Date()) {
        for exerciseLog in exerciseLogs where !exerciseLog.completed {
            exerciseLog.completed = true
            
            for setLog in exerciseLog.setLogs where !setLog.completed && !setLog.skipped {
                setLog.skip()
            }
        }
        
        end = date
        completed = true
    }
    
    func getTotalReps(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Int {
        return exerciseLogs.reduce(0) { $0 + $1.getTotalReps(includeWarmUp, includeDropSet, includeCoolDown) }
    }
    
    func getTotalWeight(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Double {
        return exerciseLogs.reduce(0) { $0 + $1.getTotalWeight(includeWarmUp, includeDropSet, includeCoolDown) }
    }
    
    func getTotalDistance(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Double {
        return exerciseLogs.reduce(0) { $0 + $1.getTotalDistance(includeWarmUp, includeDropSet, includeCoolDown) }
    }
    
    func getTotalTime(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Double {
        return exerciseLogs.reduce(0) { $0 + $1.getTotalTime(includeWarmUp, includeDropSet, includeCoolDown) }
    }
    
    func getLength() -> Double {
        let end = completed ? end : Date()
        return end.timeIntervalSince(start)
    }
    
    func getMuscleGroupBreakdown() -> [MuscleGroup] {
        var muscleGroups: [MuscleGroup] = []
        
        // swiftlint:disable line_length
        for log in exerciseLogs where log.setLogs.contains(where: { $0.completed }) && !muscleGroups.contains(MuscleGroup(rawValue: (log.exercise?.exercise?.muscleGroup)?.rawValue ?? "Other") ?? .other) {
            muscleGroups.append(MuscleGroup(rawValue: (log.exercise?.exercise?.muscleGroup)?.rawValue ?? "Other") ?? .other)
        }
        // swiftlint:enable line_length
        
        return muscleGroups
    }
    
    func getProgress() -> Double {
        var completed: Double = 0
        var total: Double = 0
        
        for exerciseLog in exerciseLogs {
            for setLog in exerciseLog.setLogs {
                total += 1
                
                if setLog.completed || setLog.skipped {
                    completed += 1
                }
            }
        }
        
        return total > 0 ? completed / total : 1
    }
}
