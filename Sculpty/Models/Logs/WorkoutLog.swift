//
//  WorkoutLog.swift
//  Sculpty
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
    var start: Date
    var end: Date
    @Relationship(deleteRule: .cascade, inverse: \ExerciseLog.workoutLog) var exerciseLogs: [ExerciseLog] = []
    
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
    
    func getTotalVolume(_ includeWarmUp: Bool, _ includeDropSet: Bool, _ includeCoolDown: Bool) -> Double {
        return exerciseLogs.reduce(0) { $0 + $1.getTotalVolume(includeWarmUp, includeDropSet, includeCoolDown) }
    }
    
    func getLength() -> Double {
        if completed {
            return end.timeIntervalSince(start)
        } else {
            return Date().timeIntervalSince(start)
        }
    }
    
    func getScore() -> Double {
        // Basic Information
        let totalWeight = getTotalWeight(false, true, false)
        let totalReps = getTotalReps(false, true, false)
        let duration = max(1.0, getLength() / 60.0)
        
        let muscleGroups: Int = Set(exerciseLogs.compactMap { $0.exercise.exercise?.muscleGroup }).count
        let exercises: Int = Set(exerciseLogs.compactMap { $0.exercise.exercise }).count
        
        // x-per-set Variables
        var weightBySet: [Double] = []
        var repsBySet: [Int] = []
        for exerciseLog in exerciseLogs {
            for setLog in exerciseLog.setLogs {
                if setLog.completed,
                   let weight = setLog.weight,
                   let reps = setLog.reps {
                    weightBySet.append(weight)
                    repsBySet.append(reps)
                }
            }
        }
        
        // Volume Score
        let volumeScore = min(100.0, max(0.0, (log10(max(1.0, (totalWeight * Double(totalReps)) / duration)) - 1.0) * 33.33))
        
        // Intensity Score
        let intensityScore = (weightBySet.isEmpty ? 0.0 : min(100.0, (weightBySet.enumerated().reduce(0.0) { sum, element in sum + element.element / (element.element * (1.0 + Double(repsBySet[element.offset]) / 30.0)) } / Double(weightBySet.count)) * 100.0))
        
        // Efficiency Score
        let efficiencyScore = (min(100.0, max(0.0, (log10(max(1.0, (totalWeight * Double(totalReps)) / duration)) - 2.0) * 25.0)) * (1.0 / (1.0 + pow(duration / 75.0 - 1.0, 2.0))))
        
        // Diversity Score
        let diversityScore = max(10.0, min(60.0, Double(muscleGroups) * 12.0 - pow(Double(muscleGroups), 1.5)) + min(40.0, Double(exercises) * 6.0 - pow(Double(exercises), 1.2)))
        
        debugLog("Volume: \(volumeScore), Intensity: \(intensityScore), Efficiency: \(efficiencyScore), Diversity: \(diversityScore)")
        // Geometric mean to balance all components (0-100 scale)
        return round(pow(volumeScore * intensityScore * efficiencyScore * diversityScore, 0.25))
    }
    
    func getMuscleGroupBreakdown() -> [MuscleGroup] {
        var muscleGroups: [MuscleGroup] = []
        
        for log in exerciseLogs {
            if !muscleGroups.contains(MuscleGroup(rawValue: (log.exercise.exercise?.muscleGroup)!.rawValue) ?? .other) {
                muscleGroups.append(MuscleGroup(rawValue: (log.exercise.exercise?.muscleGroup)!.rawValue) ?? .other)
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
        
        return completed / total
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
        start = try container.decode(Date.self, forKey: .start)
        end = try container.decode(Date.self, forKey: .end)
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
