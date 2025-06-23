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
    
    init(workout: Workout, started: Bool = false, completed: Bool = false, start: Date = Date(), end: Date = Date(timeIntervalSince1970: 0), exerciseLogs: [ExerciseLog]? = nil) {
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
        for exercise in workout?.exercises ?? [] {
            if exerciseLogs.firstIndex (where: { $0.exercise?.id == exercise.id }) == -1 {
                exerciseLogs.append(ExerciseLog(index: exercise.index, exercise: exercise))
            }
        }
        
        for exerciseLog in exerciseLogs {
            if workout?.exercises.firstIndex (where: { $0.id == exerciseLog.exercise?.id }) == -1 {
                exerciseLogs.remove(at: exerciseLogs.firstIndex(of: exerciseLog)!)
            }
        }
    }
    
    func startWorkout() {
        start = Date()
        started = true
    }
    
    func finishWorkout() {
        for exerciseLog in exerciseLogs {
            if !exerciseLog.completed {
                exerciseLog.completed = true
                for setLog in exerciseLog.setLogs {
                    if !setLog.completed && !setLog.skipped {
                        setLog.skip()
                    }
                }
            }
        }
        
        end = Date()
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
        if completed {
            return end.timeIntervalSince(start)
        } else {
            let setLog: SetLog? = exerciseLogs.compactMap { $0.getLastFinishedSetLog() }.sorted { $0.end < $1.end }.last
            
            if let setLog = setLog {
                return setLog.end.timeIntervalSince(start)
            } else {
                return 0
            }
        }
    }
    
    func getMuscleGroupBreakdown() -> [MuscleGroup] {
        var muscleGroups: [MuscleGroup] = []
        
        for log in exerciseLogs {
            if !muscleGroups.contains(MuscleGroup(rawValue: (log.exercise?.exercise?.muscleGroup)!.rawValue) ?? .other) {
                muscleGroups.append(MuscleGroup(rawValue: (log.exercise?.exercise?.muscleGroup)!.rawValue) ?? .other)
            }
        }
        
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
