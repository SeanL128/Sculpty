//
//  DataHandler.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/20/25.
//

import Foundation

class DataHandler {
    var workoutLogs: [WorkoutLog]
    var workouts: [Workout] = []
    var exercises: [Exercise] = []
    
    // Overall
    var overallTotalTime: Double = 0
    var overallMuscleGroupRepBreakdown: [MuscleGroup: Int] = [:]
    var overallMuscleGroupRepRanges: [(muscleGroup: MuscleGroup, range: Range<Double>)] = []
    var overallMuscleGroupWeightBreakdown: [MuscleGroup: Double] = [:]
    var overallMuscleGroupWeightRanges: [(muscleGroup: MuscleGroup, range: Range<Double>)] = []
    
    // Workout
    var workoutRepsDict: [Workout: Int] = [:]
    var workoutWeightDict: [Workout: Double] = [:]
    var workoutTimeDict: [Workout: Double] = [:]
    
    var workoutLogsDict: [Workout: [WorkoutLog]] = [:]
    
    var workoutMuscleGroupRepBreakdown: [Workout: [MuscleGroup: Int]] = [:]
    var workoutMuscleGroupRepRanges: [Workout: [(muscleGroup: MuscleGroup, range: Range<Double>)]] = [:]
    var workoutMuscleGroupWeightBreakdown: [Workout: [MuscleGroup: Double]] = [:]
    var workoutMuscleGroupWeightRanges: [Workout: [(muscleGroup: MuscleGroup, range: Range<Double>)]] = [:]
    
    // Exercise
    var exerciseRepsDict: [Exercise: Int] = [:]
    var exerciseWeightDict: [Exercise: Double] = [:]
    
    var exerciseLogsDict: [Exercise: [ExerciseLog]] = [:]
    
    
    
    // Init
    init(workoutLogs: [WorkoutLog]) {
        self.workoutLogs = workoutLogs
        
        var totalReps: Int = 0
        var totalWeight: Double = 0
        
        for workoutLog in workoutLogs {
            if workoutLog.started {
                let workout = workoutLog.workout
                let workoutReps = workoutLog.getTotalReps()
                let workoutWeight = workoutLog.getTotalWeight()
                let length = workoutLog.completed ? workoutLog.getLength() : 0
                workoutMuscleGroupRepBreakdown[workout] = workoutMuscleGroupRepBreakdown[workout] ?? [:]
                workoutMuscleGroupWeightBreakdown[workout] = workoutMuscleGroupWeightBreakdown[workout] ?? [:]
                workoutMuscleGroupRepRanges[workout] = workoutMuscleGroupRepRanges[workout] ?? []
                workoutMuscleGroupWeightRanges[workout] = workoutMuscleGroupWeightRanges[workout] ?? []
                
                totalReps += workoutReps
                totalWeight += workoutWeight
                overallTotalTime += length
                
                // Workouts Array
                if !workouts.contains(workout) {
                    workouts.append(workout)
                }
                
                // Workout Reps Dictonary
                workoutRepsDict[workout] = (workoutRepsDict[workout] ?? 0) + workoutReps
                
                // Workout Weight Dictionary
                workoutWeightDict[workout] = (workoutWeightDict[workout] ?? 0) + workoutWeight
                
                // Workout Time Dictionary
                workoutTimeDict[workout] = (workoutTimeDict[workout] ?? 0) + length
                
                // Workout Logs Dictionary
                if workoutLogsDict[workout] == nil {
                    workoutLogsDict[workout] = [workoutLog]
                } else {
                    workoutLogsDict[workout]!.append(workoutLog)
                }
                
                // Add .overall to this workout's workoutMuscleGroupRepBreakdown
                workoutMuscleGroupRepBreakdown[workout]![.overall] = (workoutMuscleGroupRepBreakdown[workout]![.overall] ?? 0) + workoutReps
                // Add .overall to this workout's workoutMuscleGroupWeightBreakdown
                workoutMuscleGroupWeightBreakdown[workout]![.overall] = (workoutMuscleGroupWeightBreakdown[workout]![.overall] ?? 0) + workoutWeight
                
                // Rep Ranges
                var repTotal: Int = 0
                workoutMuscleGroupRepRanges[workout] = workoutMuscleGroupRepBreakdown[workout]!.map {
                    let newTotal = repTotal + $0.value
                    let result = (muscleGroup: $0.key, range: Double(repTotal) ..< Double(newTotal))
                    repTotal = newTotal
                    return result
                }
                
                // Weight Ranges
                var weightTotal: Double = 0
                workoutMuscleGroupWeightRanges[workout] = workoutMuscleGroupWeightBreakdown[workout]!.map {
                    let newTotal = weightTotal + $0.value
                    let result = (muscleGroup: $0.key, range: Double(weightTotal) ..< Double(newTotal))
                    weightTotal = newTotal
                    return result
                }
                
                for exerciseLog in workoutLog.exerciseLogs {
                    let workoutExercise = exerciseLog.exercise
                    let exercise = workoutExercise.exercise!
                    let muscleGroup = exercise.muscleGroup ?? .other
                    let exerciseReps = exerciseLog.getTotalReps()
                    let exerciseWeight = exerciseLog.getTotalWeight()
                    
                    // Exercises Array
                    if !exercises.contains(exercise) {
                        exercises.append(exercise)
                    }
                    
                    // Overall Reps Breakdown
                    overallMuscleGroupRepBreakdown[muscleGroup] = (overallMuscleGroupRepBreakdown[muscleGroup] ?? 0) + exerciseReps
                    
                    // Workout Reps Breakdown
                    workoutMuscleGroupRepBreakdown[workout]![muscleGroup] = (workoutMuscleGroupRepBreakdown[workout]![muscleGroup] ?? 0) + exerciseReps
                    
                    // Overall Weight Breakdown
                    overallMuscleGroupWeightBreakdown[muscleGroup] = (overallMuscleGroupWeightBreakdown[muscleGroup] ?? 0) + exerciseWeight
                    
                    // Workout Weight Breakdown
                    workoutMuscleGroupWeightBreakdown[workout]![muscleGroup] = (workoutMuscleGroupWeightBreakdown[workout]![muscleGroup] ?? 0) + exerciseWeight
                    
                    // Exercise Reps Dictionary
                    exerciseRepsDict[exercise] = (exerciseRepsDict[exercise] ?? 0) + exerciseReps
                    
                    // Exercise Weight Dictionary
                    exerciseWeightDict[exercise] = (exerciseWeightDict[exercise] ?? 0) + exerciseWeight
                    
                    // Exercise Logs Dictionary
                    if exerciseLogsDict[exercise] == nil {
                        exerciseLogsDict[exercise] = [exerciseLog]
                    } else {
                        exerciseLogsDict[exercise]!.append(exerciseLog)
                    }
                }
            }
        }
        
        // Add .overall to overallMuscleGroupRepBreakdown
        overallMuscleGroupRepBreakdown[.overall] = totalReps
        // Add .overall to overallMuscleGroupWeightBreakdown
        overallMuscleGroupWeightBreakdown[.overall] = totalWeight
        
        // Rep Ranges
        var repTotal: Int = 0
        overallMuscleGroupRepRanges = overallMuscleGroupRepBreakdown.map {
            let newTotal = repTotal + $0.value
            let result = (muscleGroup: $0.key, range: Double(repTotal) ..< Double(newTotal))
            repTotal = newTotal
            return result
        }
        
        // Weight Ranges
        var weightTotal: Double = 0
        overallMuscleGroupWeightRanges = overallMuscleGroupWeightBreakdown.map {
            let newTotal = weightTotal + $0.value
            let result = (muscleGroup: $0.key, range: Double(weightTotal) ..< Double(newTotal))
            weightTotal = newTotal
            return result
        }
    }
}
