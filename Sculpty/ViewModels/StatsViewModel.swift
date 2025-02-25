//
//  StatsViewModel.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/20/25.
//

import Foundation
import SwiftUI
import SwiftUICharts
import SwiftData

class StatsViewModel: ObservableObject {
    @AppStorage(UserKeys.includeWarmUp.rawValue) private var includeWarmUp: Bool = true
    @AppStorage(UserKeys.includeDropSet.rawValue) private var includeDropSet: Bool = true
    @AppStorage(UserKeys.includeCoolDown.rawValue) private var includeCoolDown: Bool = true
    
    var data: DataHandler? = nil
    
    func update(workoutLogs: [WorkoutLog], measurements: [Measurement]) {
        self.data = DataHandler(workoutLogs: workoutLogs, measurements: measurements)
    }
    
    // General Variables
    var title: String {
        if selectedView == "Overall" {
            return "Stats - Overall"
        } else if selectedView == "Workout" {
            return "Stats - Workout (\(selectedWorkout!.name))"
        } else if selectedView == "Exercise" {
            return "Stats - Exercise (\(selectedExercise!.name))"
        } else if selectedView == "Measurement" {
            return "Stats - \(selectedMeasurementType!.rawValue)"
        }
        else {
            return "Stats"
        }
    }
    var showCharts: Bool {
        return ["Overall", "Workout"].contains(selectedView)
    }
    var showGraph: Bool {
        return selectedView != "Overall"
    }
    var workoutRelated: Bool {
        return ["Overall", "Workout", "Exercise"].contains(selectedView)
    }
    
    
    
    // MARK: Workout-related Stats
    
    // General Variables
    @Published var showRepsBreakdown: Bool = false
    @Published var showWeightBreakdown: Bool = false
    
    
    // Selection Variables
    @Published private var selectedView: String = "Overall"
    @Published private var selectedWorkout: Workout?
    @Published private var selectedExercise: Exercise?
    
    var selectedMuscleGroupRepBreakdown: [MuscleGroup: Int] {
        if selectedView == "Overall" {
            return data?.overallMuscleGroupRepBreakdown ?? [:]
        } else if selectedView == "Workout" {
            return data?.workoutMuscleGroupRepBreakdown[selectedWorkout!] ?? [:]
        } else {
            return [:]
        }
    }
    var selectedMuscleGroupRepArrayBreakdown: [MuscleGroup: [Int]] {
        if selectedView == "Overall" {
            return data?.overallMuscleGroupRepArrayBreakdown ?? [:]
        } else if selectedView == "Workout" {
            return data?.workoutMuscleGroupRepArrayBreakdown[selectedWorkout!] ?? [:]
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
    var selectedMuscleGroupRepBreakdownChartData: [(Double, String, Color)] {
        var toReturn: [(Double, String, Color)] = []
        
        for key in MuscleGroup.displayOrder {
            if key != .overall && selectedMuscleGroupRepBreakdown.keys.contains(key) {
                toReturn.append((Double(selectedMuscleGroupRepBreakdown[key] ?? 0), "\(key.rawValue.capitalized)", MuscleGroup.colorMap[key] ?? .gray))
            }
        }
        
        return toReturn
    }
    var selectedMuscleGroupRepBreakdownLineData: [([Double], GradientColor)] {
        var toReturn: [([Double], GradientColor)] = []
        
        for key in MuscleGroup.displayOrder {
            if key != .overall && selectedMuscleGroupRepArrayBreakdown.keys.contains(key) {
                toReturn.append(((selectedMuscleGroupRepArrayBreakdown[key] ?? []).map { Double($0) }, GradientColor(start: MuscleGroup.colorMap[key] ?? .gray, end: MuscleGroup.colorMap[key] ?? .gray)))
            }
        }
        
        return toReturn
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
    var selectedMuscleGroupWeightArrayBreakdown: [MuscleGroup: [Double]] {
        if selectedView == "Overall" {
            return data?.overallMuscleGroupWeightArrayBreakdown ?? [:]
        } else if selectedView == "Workout" {
            return data?.workoutMuscleGroupWeightArrayBreakdown[selectedWorkout!] ?? [:]
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
    var selectedMuscleGroupWeightBreakdownChartData: [(Double, String, Color)] {
        var toReturn: [(Double, String, Color)] = []
        
        for key in MuscleGroup.displayOrder {
            if key != .overall && selectedMuscleGroupWeightBreakdown.keys.contains(key) {
                toReturn.append((selectedMuscleGroupWeightBreakdown[key] ?? 0, "\(key.rawValue.capitalized)", MuscleGroup.colorMap[key] ?? .gray))
            }
        }
        
        return toReturn
    }
    var selectedMuscleGroupWeightBreakdownLineData: [([Double], GradientColor)] {
        var toReturn: [([Double], GradientColor)] = []
        
        for key in MuscleGroup.displayOrder {
            if key != .overall && selectedMuscleGroupWeightArrayBreakdown.keys.contains(key) {
                toReturn.append((selectedMuscleGroupWeightArrayBreakdown[key] ?? [], GradientColor(start: MuscleGroup.colorMap[key] ?? .gray, end: MuscleGroup.colorMap[key] ?? .gray)))
            }
        }
        
        return toReturn
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
    }
    
    func selectWorkout(workout: Workout) {
        selectedView = "Workout"
        selectedWorkout = workout
    }
    
    func selectExercise(exercise: Exercise) {
        selectedView = "Exercise"
        selectedExercise = exercise
    }
    
    func getWorkoutGraphInfo() -> [([Double], GradientColor)] {
        let repsInfo = getWorkoutGraphRepsInfo()
        let weightInfo = getWorkoutGraphWeightInfo()
        if repsInfo != nil && weightInfo != nil {
            return [(repsInfo!, GradientColor(start: ColorManager.text, end: ColorManager.text)), (weightInfo!, GradientColor(start: Color.accentColor, end: Color.accentColor))]
        } else {
            return []
        }
    }
    
//    func getWorkoutGraphRepsInfo() -> ([Double], GradientColor)? {
//        if selectedView == "Workout" {
//            return ((data?.workoutRepsArrayDict[selectedWorkout!] ?? []).map { Double($0) }, GradientColor(start: ColorManager.text, end: ColorManager.text))
//        } else if selectedView == "Exercise" {
//            return ((data?.exerciseRepsArrayDict[selectedExercise!] ?? []).map { Double($0) }, GradientColor(start: ColorManager.text, end: ColorManager.text))
//        } else {
//            return nil
//        }
//    }
//    
//    func getWorkoutGraphWeightInfo() -> ([Double], GradientColor)? {
//        if selectedView == "Workout" {
//            return (data?.workoutWeightArrayDict[selectedWorkout!] ?? [], GradientColor(start: ColorManager.text, end: ColorManager.text))
//        } else if selectedView == "Exercise" {
//            return (data?.exerciseWeightArrayDict[selectedExercise!] ?? [], GradientColor(start: ColorManager.text, end: ColorManager.text))
//        } else {
//            return nil
//        }
//    }
    
    func getWorkoutGraphRepsInfo() -> [Double]? {
        if selectedView == "Workout" {
            return (data?.workoutRepsArrayDict[selectedWorkout!] ?? []).map { Double($0) }
        } else if selectedView == "Exercise" {
            return (data?.exerciseRepsArrayDict[selectedExercise!] ?? []).map { Double($0) }
        } else {
            return nil
        }
    }
    
    func getWorkoutGraphWeightInfo() -> [Double]? {
        if selectedView == "Workout" {
            return data?.workoutWeightArrayDict[selectedWorkout!] ?? []
        } else if selectedView == "Exercise" {
            return data?.exerciseWeightArrayDict[selectedExercise!] ?? []
        } else {
            return nil
        }
    }
    
    func getWorkoutRawGraphInfo() -> [(Double, Double, Date)] {
        if selectedView == "Exercise" || selectedView == "Workout" {
            var arr: [(Double, Double, Date)] = []
            
            for workoutLog in (data?.workoutLogs ?? []).filter({ $0.completed }) {
                var reps: Double = 0
                var weight: Double = 0
                
                if selectedView == "Exercise" {
                    for exerciseLog in workoutLog.exerciseLogs {
                        if exerciseLog.exercise.exercise == selectedExercise ?? nil {
                            reps += Double(exerciseLog.getTotalReps(includeWarmUp, includeDropSet, includeCoolDown))
                            weight += exerciseLog.getTotalWeight(includeWarmUp, includeDropSet, includeCoolDown)
                        }
                    }
                } else {
                    reps = Double(workoutLog.getTotalReps(includeWarmUp, includeDropSet, includeCoolDown))
                    weight = workoutLog.getTotalWeight(includeWarmUp, includeDropSet, includeCoolDown)
                }
                
                arr.append((reps, weight, workoutLog.start))
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
                    reps += exerciseLog.getTotalReps(includeWarmUp, includeDropSet, includeCoolDown)
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
                    weight += exerciseLog.getTotalWeight(includeWarmUp, includeDropSet, includeCoolDown)
                }
            }
        }
        
        return weight
    }
    
    
    
    // MARK: Measurement-related Stats
    
    // Selection Variables
    @Published var selectedMeasurementType: MeasurementType?
    
    // Functions
    func selectMeasurementType(measurementType: MeasurementType) {
        selectedView = "Measurement"
        selectedMeasurementType = measurementType
    }
}
