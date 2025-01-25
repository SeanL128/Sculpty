//
//  WorkoutLog.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftData

@Model
class WorkoutLog: Identifiable, Codable {
    @Attribute(.unique) var id: UUID = UUID()
    
    var workout: Workout
    var started: Bool
    var completed: Bool
    var start: Double
    var end: Double
    var exerciseLogs: [ExerciseLog] = []
    
    init(workout: Workout, started: Bool = false, completed: Bool = false, start: Double = Date().timeIntervalSince1970.rounded(), end: Double = 0, exerciseLogs: [ExerciseLog]? = nil) {
        self.workout = workout
        self.started = started
        self.completed = completed
        self.start = start
        self.end = end
        
        if exerciseLogs != nil {
            self.exerciseLogs = exerciseLogs!
        } else {
            for exercise in workout.exercises {
                self.exerciseLogs.append(ExerciseLog(index: exercise.index, exercise: exercise))
            }
        }
    }
    
    func updateWorkoutLog() {
        for exercise in workout.exercises {
            if exerciseLogs.firstIndex (where: { $0.exercise.id == exercise.id }) == -1 {
                exerciseLogs.append(ExerciseLog(index: exercise.index, exercise: exercise))
            }
        }
        
        for exerciseLog in exerciseLogs {
            if workout.exercises.firstIndex (where: { $0.id == exerciseLog.exercise.id }) == -1 {
                exerciseLogs.remove(at: exerciseLogs.firstIndex(of: exerciseLog)!)
            }
        }
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
        
        completed = true
    }

    
    func getTotalReps() -> Int {
        var reps: Int = 0
        
        for exerciseLog in exerciseLogs {
            reps += exerciseLog.getTotalReps()
        }
        
        return reps
    }
    
    func getTotalWeight() -> Double {
        var weight: Double = 0
        
        for exerciseLog in exerciseLogs {
            weight += exerciseLog.getTotalWeight()
        }
        
        return weight
    }
    
    func getLength() -> Double {
        return end - start
    }
    
    enum CodingKeys: String, CodingKey {
        case id, workout, started, completed, start, end, exerciseLogs
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        workout = try container.decode(Workout.self, forKey: .workout)
        started = try container.decode(Bool.self, forKey: .started)
        completed = try container.decode(Bool.self, forKey: .completed)
        start = try container.decode(Double.self, forKey: .start)
        end = try container.decode(Double.self, forKey: .end)
        exerciseLogs = try container.decode([ExerciseLog].self, forKey: .exerciseLogs)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(workout, forKey: .workout)
        try container.encode(started, forKey: .started)
        try container.encode(completed, forKey: .completed)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(exerciseLogs, forKey: .exerciseLogs)
    }
}
