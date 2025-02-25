//
//  DataHandler.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/20/25.
//

import Foundation
import SwiftUI

class DataHandler {
    @AppStorage(UserKeys.includeWarmUp.rawValue) private var includeWarmUp: Bool = true
    @AppStorage(UserKeys.includeDropSet.rawValue) private var includeDropSet: Bool = true
    @AppStorage(UserKeys.includeCoolDown.rawValue) private var includeCoolDown: Bool = true
    
    
    // MARK: Workout-related Data
    var workoutLogs: [WorkoutLog]
    var workouts: [Workout] = []
    var exercises: [Exercise] = []
    
    // Overall
    var overallTotalTime: Double = 0
    var overallMuscleGroupRepBreakdown: [MuscleGroup: Int] = [:]
    var overallMuscleGroupRepArrayBreakdown: [MuscleGroup: [Int]] = [:]
    var overallMuscleGroupRepRanges: [(muscleGroup: MuscleGroup, range: Range<Double>)] = []
    var overallMuscleGroupWeightBreakdown: [MuscleGroup: Double] = [:]
    var overallMuscleGroupWeightArrayBreakdown: [MuscleGroup: [Double]] = [:]
    var overallMuscleGroupWeightRanges: [(muscleGroup: MuscleGroup, range: Range<Double>)] = []
    
    // Workout
    var workoutRepsDict: [Workout: Int] = [:]
    var workoutRepsArrayDict: [Workout: [Int]] = [:]
    var workoutWeightDict: [Workout: Double] = [:]
    var workoutWeightArrayDict: [Workout: [Double]] = [:]
    var workoutTimeDict: [Workout: Double] = [:]
    
    var workoutLogsDict: [Workout: [WorkoutLog]] = [:]
    
    var workoutMuscleGroupRepBreakdown: [Workout: [MuscleGroup: Int]] = [:]
    var workoutMuscleGroupRepArrayBreakdown: [Workout: [MuscleGroup: [Int]]] = [:]
    var workoutMuscleGroupRepRanges: [Workout: [(muscleGroup: MuscleGroup, range: Range<Double>)]] = [:]
    var workoutMuscleGroupWeightBreakdown: [Workout: [MuscleGroup: Double]] = [:]
    var workoutMuscleGroupWeightArrayBreakdown: [Workout: [MuscleGroup: [Double]]] = [:]
    var workoutMuscleGroupWeightRanges: [Workout: [(muscleGroup: MuscleGroup, range: Range<Double>)]] = [:]
    
    // Exercise
    var exerciseRepsDict: [Exercise: Int] = [:]
    var exerciseRepsArrayDict: [Exercise: [Int]] = [:]
    var exerciseWeightDict: [Exercise: Double] = [:]
    var exerciseWeightArrayDict: [Exercise: [Double]] = [:]
    
    var exerciseLogsDict: [Exercise: [ExerciseLog]] = [:]
    
    
    // MARK: Measurement-related Data
    var measurements: [Measurement]
    var measurementTypes: [MeasurementType] = []
    
    var measurementTypeBreakdown: [MeasurementType: [Measurement]] = [:]
    
    
    // Init
    init(workoutLogs: [WorkoutLog], measurements: [Measurement]) {
        self.workoutLogs = workoutLogs
        self.measurements = measurements
        
        setWorkoutVariables(workoutLogs: workoutLogs)
        setMeasurementVariables(measurements: measurements)
    }
    
    private func setWorkoutVariables(workoutLogs: [WorkoutLog]) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            var totalReps: Int = 0
            var totalWeight: Double = 0
            
            for workoutLog in workoutLogs {
                if workoutLog.started {
                    let workout = workoutLog.workout
                    let workoutReps = workoutLog.getTotalReps(includeWarmUp, includeDropSet, includeCoolDown)
                    let workoutWeight = workoutLog.getTotalWeight(includeWarmUp, includeDropSet, includeCoolDown)
                    let length = workoutLog.completed ? workoutLog.getLength() : 0
                    workoutMuscleGroupRepBreakdown[workout] = workoutMuscleGroupRepBreakdown[workout] ?? [:]
                    workoutMuscleGroupRepArrayBreakdown[workout] = workoutMuscleGroupRepArrayBreakdown[workout] ?? [:]
                    workoutMuscleGroupWeightBreakdown[workout] = workoutMuscleGroupWeightBreakdown[workout] ?? [:]
                    workoutMuscleGroupWeightArrayBreakdown[workout] = workoutMuscleGroupWeightArrayBreakdown[workout] ?? [:]
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
                    
                    // Workout Reps Array Dictionary
                    if workoutRepsArrayDict[workout] == nil {
                        workoutRepsArrayDict[workout] = [workoutReps]
                    } else {
                        workoutRepsArrayDict[workout]?.append(workoutReps)
                    }
                    
                    // Workout Weight Dictionary
                    workoutWeightDict[workout] = (workoutWeightDict[workout] ?? 0) + workoutWeight
                    
                    // Workout Weight Array Dictionary
                    if workoutWeightArrayDict[workout] == nil {
                        workoutWeightArrayDict[workout] = [workoutWeight]
                    } else {
                        workoutWeightArrayDict[workout]?.append(workoutWeight)
                    }
                    
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
                    // Add .overall to this workout's workoutMuscleGroupRepArrayBreakdown
                    if workoutMuscleGroupRepArrayBreakdown[workout]![.overall] == nil {
                        workoutMuscleGroupRepArrayBreakdown[workout]![.overall] = [workoutReps]
                    } else {
                        workoutMuscleGroupRepArrayBreakdown[workout]![.overall]?.append(workoutReps)
                    }
                    // Add .overall to this workout's workoutMuscleGroupWeightBreakdown
                    workoutMuscleGroupWeightBreakdown[workout]![.overall] = (workoutMuscleGroupWeightBreakdown[workout]![.overall] ?? 0) + workoutWeight
                    // Add .overall to this workout's workoutMuscleGroupWeightArrayBreakdown
                    if workoutMuscleGroupWeightArrayBreakdown[workout]![.overall] == nil {
                        workoutMuscleGroupWeightArrayBreakdown[workout]![.overall] = [workoutWeight]
                    } else {
                        workoutMuscleGroupWeightArrayBreakdown[workout]![.overall]?.append(workoutWeight)
                    }
                    
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
                        let exerciseReps = exerciseLog.getTotalReps(includeWarmUp, includeDropSet, includeCoolDown)
                        let exerciseWeight = exerciseLog.getTotalWeight(includeWarmUp, includeDropSet, includeCoolDown)
                        
                        // Exercises Array
                        if !exercises.contains(exercise) {
                            exercises.append(exercise)
                        }
                        
                        // Overall Reps Breakdown
                        overallMuscleGroupRepBreakdown[muscleGroup] = (overallMuscleGroupRepBreakdown[muscleGroup] ?? 0) + exerciseReps
                        
                        // Overall Reps Array Breakdown
                        if overallMuscleGroupRepArrayBreakdown[muscleGroup] == nil {
                            overallMuscleGroupRepArrayBreakdown[muscleGroup] = [exerciseReps]
                        } else {
                            overallMuscleGroupRepArrayBreakdown[muscleGroup]?.append(exerciseReps)
                        }
                        
                        // Workout Reps Breakdown
                        workoutMuscleGroupRepBreakdown[workout]![muscleGroup] = (workoutMuscleGroupRepBreakdown[workout]![muscleGroup] ?? 0) + exerciseReps
                        
                        // Workout Reps Array Breakdown
                        if workoutMuscleGroupRepArrayBreakdown[workout]![muscleGroup] == nil {
                            workoutMuscleGroupRepArrayBreakdown[workout]![muscleGroup] = [exerciseReps]
                        } else {
                            workoutMuscleGroupRepArrayBreakdown[workout]![muscleGroup]?.append(exerciseReps)
                        }
                        
                        // Overall Weight Breakdown
                        overallMuscleGroupWeightBreakdown[muscleGroup] = (overallMuscleGroupWeightBreakdown[muscleGroup] ?? 0) + exerciseWeight
                        
                        // Overall Weight Array Breakdown
                        if overallMuscleGroupWeightArrayBreakdown[muscleGroup] == nil {
                            overallMuscleGroupWeightArrayBreakdown[muscleGroup] = [exerciseWeight]
                        } else {
                            overallMuscleGroupWeightArrayBreakdown[muscleGroup]?.append(exerciseWeight)
                        }
                        
                        // Workout Weight Breakdown
                        workoutMuscleGroupWeightBreakdown[workout]![muscleGroup] = (workoutMuscleGroupWeightBreakdown[workout]![muscleGroup] ?? 0) + exerciseWeight
                        
                        // Workout Weight Array Breakdown
                        if workoutMuscleGroupWeightArrayBreakdown[workout]![muscleGroup] == nil {
                            workoutMuscleGroupWeightArrayBreakdown[workout]![muscleGroup] = [exerciseWeight]
                        } else {
                            workoutMuscleGroupWeightArrayBreakdown[workout]![muscleGroup]?.append(exerciseWeight)
                        }
                        
                        // Exercise Reps Dictionary
                        exerciseRepsDict[exercise] = (exerciseRepsDict[exercise] ?? 0) + exerciseReps
                        
                        // Exercise Reps Array Dictionary
                        if exerciseRepsArrayDict[exercise] == nil {
                            exerciseRepsArrayDict[exercise] = [exerciseReps]
                        } else {
                            exerciseRepsArrayDict[exercise]?.append(exerciseReps)
                        }
                        
                        // Exercise Weight Dictionary
                        exerciseWeightDict[exercise] = (exerciseWeightDict[exercise] ?? 0) + exerciseWeight
                        
                        // Exercise Weight Array Dictionary
                        if exerciseWeightArrayDict[exercise] == nil {
                            exerciseWeightArrayDict[exercise] = [exerciseWeight]
                        } else {
                            exerciseWeightArrayDict[exercise]?.append(exerciseWeight)
                        }
                        
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
    
    private func setMeasurementVariables(measurements: [Measurement]) {
        for measurement in measurements {
            let type: MeasurementType = measurement.type
            
            if !measurementTypes.contains(type) {
                measurementTypes.append(type)
            }
            
            if measurementTypeBreakdown[type] == nil {
                measurementTypeBreakdown[type] = [measurement]
            } else {
                measurementTypeBreakdown[type]!.append(measurement)
            }
        }
    }
    
    func filter(selectedRange: TimeRange, rangeStart: Date? = nil, rangeEnd: Date? = nil) {
        setWorkoutVariables(workoutLogs: getFilteredLogs(selectedRange: selectedRange, rangeStart: rangeStart, rangeEnd: rangeEnd))
    }
    
    private func getFilteredLogs (selectedRange: TimeRange, rangeStart: Date? = nil, rangeEnd: Date? = nil) -> [WorkoutLog] {
        let calendar = Calendar.current
        
        switch selectedRange {
        case .week:
            guard let filterDate = calendar.date(byAdding: .day, value: -7, to: Date()) else { return [] }
            
            return workoutLogs.filter { $0.end >= filterDate }
            
        case .month:
            guard let filterDate = calendar.date(byAdding: .day, value: -30, to: Date()) else { return [] }
            
            return workoutLogs.filter { $0.end >= filterDate }
            
        case .custom:
            guard let start = rangeStart, let end = rangeEnd else { return [] }
            
            return workoutLogs.filter { $0.end >= start && $0.start <= end }
            
        case .all:
            return workoutLogs
        }
    }
}
