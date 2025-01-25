//
//  StatsViewModel.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/20/25.
//

import Foundation
import SwiftUI
import Charts
import SwiftData

class StatsViewModel: ObservableObject {
    var data: DataHandler? = nil
    
    func updateWorkoutLogs(workoutLogs: [WorkoutLog]) {
        self.data = DataHandler(workoutLogs: workoutLogs)
    }
    
    
    // General Variables
    @Published var showRepsBreakdown: Bool = false
    @Published var showWeightBreakdown: Bool = false
    var title: String {
        if selectedView == "Overall" {
            return "Stats - Overall"
        } else if selectedView == "Workout" {
            return "Stats - Workout (\(selectedWorkout!.name))"
        } else {
            return "Stats - Exercise (\(selectedExercise!.name))"
        }
    }
    var showCharts: Bool {
        return selectedView != "Exercise"
    }
    var showGraph: Bool {
        return selectedView != "Overall"
    }
    
    
    // Selection Variables
    @Published private var selectedView: String = "Overall"
    @Published private var selectedWorkout: Workout?
    @Published private var selectedExercise: Exercise?
    
    @State var selectedGraphView: String = "1M"
    private var graphUnix: Double {
        switch selectedGraphView {
        case "1W":
            return 604800
        case "1M":
            return 2592000
        case "3M":
            return 7776000
        case "6M":
            return 15552000
        case "1Y":
            return 31536000
        case "2Y":
            return 63072000
        default:
            return 157680000
        }
    }
    
    var selectedMuscleGroupRepBreakdown: [MuscleGroup: Int] {
        if selectedView == "Overall" {
            return data?.overallMuscleGroupRepBreakdown ?? [:]
        } else if selectedView == "Workout" {
            return data?.workoutMuscleGroupRepBreakdown[selectedWorkout!] ?? [:]
        } else {
            return [:]
        }
    }
    var selectedMuscleGroupRepRanges: [(muscleGroup: MuscleGroup, range: Range<Double>)] {
        if selectedView == "Overall" {
            return data?.overallMuscleGroupRepRanges ?? []
        } else if selectedView == "Workout" {
            return data?.workoutMuscleGroupRepRanges[selectedWorkout!] ?? []
        } else {
            return []
        }
    }
    
    var selectedMuscleGroupWeightBreakdown: [MuscleGroup: Double] {
        if selectedView == "Overall" {
            return data?.overallMuscleGroupWeightBreakdown ?? [:]
        } else if selectedView == "Workout" {
            return data?.workoutMuscleGroupWeightBreakdown[selectedWorkout!] ?? [:]
        } else {
            return [:]
        }
    }
    var selectedMuscleGroupWeightRanges: [(muscleGroup: MuscleGroup, range: Range<Double>)] {
        if selectedView == "Overall" {
            return data?.overallMuscleGroupWeightRanges ?? []
        } else if selectedView == "Workout" {
            return data?.workoutMuscleGroupWeightRanges[selectedWorkout!] ?? []
        } else {
            return []
        }
    }
    
    var selectedExerciseInfo: ([ExerciseLog], Int, Double) {
        if selectedView == "Exercise" {
            return (data?.exerciseLogsDict[selectedExercise!] ?? [], data?.exerciseRepsDict[selectedExercise!] ?? 0, data?.exerciseWeightDict[selectedExercise!] ?? 0)
        } else {
            return ([], 0, 0)
        }
    }
    
    var selectedTotalTime: Double {
        if selectedView == "Overall" {
            return data?.overallTotalTime ?? 0
        } else if selectedView == "Workout" {
            return data?.workoutTimeDict[selectedWorkout!] ?? 0
        } else {
            return 0
        }
    }
    
    
    // Functions
    func selectOverall() {
        selectedView = "Overall"
        selectedWorkout = nil
        selectedExercise = nil
    }
    
    func selectWorkout(workout: Workout) {
        selectedView = "Workout"
        selectedWorkout = workout
        selectedExercise = nil
    }
    
    func selectExercise(exercise: Exercise) {
        selectedView = "Exercise"
        selectedWorkout = nil
        selectedExercise = exercise
    }
    
    func normalizeValue(_ value: Double, min: Double, max: Double) -> Double {
        return (value - min) / (max - min)
    }
    
    func getGraphInfo() -> [(Double, Double, Double)] {
        if selectedView == "Exercise" || selectedView == "Workout" {
            var arr: [(Double, Double, Double)] = []
            
            var repsMin: Double = Double.greatestFiniteMagnitude
            var repsMax: Double = Double.leastNonzeroMagnitude
            var weightMin: Double = Double.greatestFiniteMagnitude
            var weightMax: Double = Double.leastNonzeroMagnitude
            
            for workoutLog in data?.workoutLogs ?? [] {
                var reps: Double = 0
                var weight: Double = 0
                
                if selectedView == "Exercise" {
                    for exerciseLog in workoutLog.exerciseLogs {
                        if exerciseLog.exercise.exercise == selectedExercise ?? nil {
                            reps += Double(exerciseLog.getTotalReps())
                            weight += exerciseLog.getTotalWeight()
                        }
                    }
                } else {
                    reps = Double(workoutLog.getTotalReps())
                    weight = workoutLog.getTotalWeight()
                }
                
                repsMin = min(repsMin, reps)
                repsMax = max(repsMax, reps)
                weightMin = min(weightMin, weight)
                weightMax = max(weightMax, weight)
                
                arr.append((reps, weight, workoutLog.start))
            }
            
            for i in arr.indices {
                arr[i].0 = normalizeValue(arr[i].0, min: repsMin, max: repsMax)
                arr[i].1 = normalizeValue(arr[i].1, min: weightMin, max: weightMax)
            }
            
            return arr.sorted(by: { $0.2 < $1.2 })
        } else {
            return []
        }
    }
    
    func getExerciseTotalReps() -> Int {
        var reps: Int = 0
        
        for workoutLog in data?.workoutLogs ?? [] {
            for exerciseLog in workoutLog.exerciseLogs {
                if exerciseLog.exercise.exercise == selectedExercise ?? nil {
                    reps += exerciseLog.getTotalReps()
                }
            }
        }
        
        return reps
    }
    
    func getExerciseTotalWeight() -> Double {
        var weight: Double = 0
        
        for workoutLog in data?.workoutLogs ?? [] {
            for exerciseLog in workoutLog.exerciseLogs {
                if exerciseLog.exercise.exercise == selectedExercise ?? nil {
                    weight += exerciseLog.getTotalWeight()
                }
            }
        }
        
        return weight
    }
    
    func getXScale() -> ClosedRange<Date> {
        let min = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - graphUnix)
        let max = Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 43200)
        return min...max
    }
}
