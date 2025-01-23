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
    
    private func getMuscleGroupBreakdownChart() -> some View {
        // Mode text to correct spots
        VStack {
            let keys = Array(selectedMuscleGroupRepBreakdown.keys)
            
            Chart {
                ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { key in
                    if key != .overall && keys.contains(key) {
                        SectorMark(
                            angle: .value(key.rawValue.capitalized, self.selectedMuscleGroupRepBreakdown[key] ?? 0),
                            innerRadius: .ratio(0.8),
                            angularInset: 2
                        )
                        .cornerRadius(3)
                        .foregroundStyle(MuscleGroup.colorMap[key]!)
                    }
                }
            }
            .scaledToFit()
            .chartForegroundStyleScale(MuscleGroup.colorKeyValuePairs)
            .chartLegend(.visible)
            .chartLegend(alignment: .center, spacing: 8)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    if let anchor = chartProxy.plotFrame {
                        let frame = geometry[anchor]
                        Text("\(self.selectedMuscleGroupRepBreakdown[.overall] ?? 0) reps")
                            .font(.title)
                            .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
            
            VStack {
                ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { key in
                    if key != .overall && keys.contains(key) {
                        Text("\(key.rawValue.capitalized): \(self.selectedMuscleGroupRepBreakdown[key] ?? 0) reps")
                    }
                }
            }
            .padding(.top)
            
            Divider()
                .padding()
            
            Chart {
                ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { key in
                    if key != .overall && keys.contains(key) {
                        SectorMark(
                            angle: .value(key.rawValue.capitalized, self.selectedMuscleGroupRepBreakdown[key] ?? 0),
                            innerRadius: .ratio(0.8),
                            angularInset: 2
                        )
                        .cornerRadius(3)
                        .foregroundStyle(MuscleGroup.colorMap[key]!)
                    }
                }
            }
            .scaledToFit()
            .chartForegroundStyleScale(MuscleGroup.colorKeyValuePairs)
            .chartLegend(.visible)
            .chartLegend(alignment: .center, spacing: 8)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    if let anchor = chartProxy.plotFrame {
                        let frame = geometry[anchor]
                        Text("\(self.selectedMuscleGroupWeightBreakdown[.overall]?.formatted() ?? 0.formatted())lbs")
                            .font(.title)
                            .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
            
            VStack {
                ForEach(MuscleGroup.displayOrder.reversed(), id: \.self) { key in
                    if key != .overall && keys.contains(key) {
                        Text("\(key.rawValue.capitalized): \(self.selectedMuscleGroupRepBreakdown[key]?.formatted() ?? 0.formatted())lbs")
                    }
                }
            }
            .padding(.top)
        }
    }
    
    private func getGraph() -> some View {
        VStack {
            Picker("Graph View", selection: $selectedGraphView) {
                ForEach(["1W", "1M", "3M", "6M", "1Y", "2Y", "5Y"], id: \.self) { value in
                    Text(value)
                        .tag(value)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            
            let info = getGraphInfo()
            
            var minReps: Double = Double.greatestFiniteMagnitude
            var maxReps: Double = 0
            var minWeight: Double = Double.greatestFiniteMagnitude
            var maxWeight: Double = 0
            
            Chart {
                ForEach(info, id: \.0) { log in
                    LineMark (
                        x: .value("Date", Date(timeIntervalSince1970: log.2)),
                        y: .value("Reps", log.0)
                    )
                    .foregroundStyle(by: .value("Value", "Reps"))
                    
                    PointMark (
                        x: .value("Date", Date(timeIntervalSince1970: log.2)),
                        y: .value("Reps", log.0)
                    )
                    .foregroundStyle(by: .value("Value", "Reps"))
                    
                    
                    LineMark (
                        x: .value("Date", Date(timeIntervalSince1970: log.2)),
                        y: .value("Weight", log.1)
                    )
                    .foregroundStyle(by: .value("Value", "Weight"))
                    
                    PointMark (
                        x: .value("Date", Date(timeIntervalSince1970: log.2)),
                        y: .value("Weight", log.1)
                    )
                    .foregroundStyle(by: .value("Value", "Weight"))
                    
                    let _ = minReps = min(minReps, log.0)
                    let _ = maxReps = max(maxReps, log.0)
                    let _ = minWeight = min(minWeight, log.0)
                    let _ = maxWeight = max(maxWeight, log.0)
                }
                .interpolationMethod(.catmullRom)
            }
            .chartForegroundStyleScale([
                "Reps": textColor,
                "Weight": .accentColor
            ])
            .chartXAxis {
                AxisMarks(position: .bottom) {
                    AxisValueLabel()
                    AxisTick()
                    AxisGridLine()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { }
            }
            .chartXScale(domain: getXScale())
            .chartYScale(domain: -0.05...1.05)
            .chartLegend(position: .bottom)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.gray.opacity(0.1))
                    .border(Color.gray, width: 1)
            }
            .clipped()
            .frame(height: 400)
            .overlay(
                Text("\(minReps.formatted())x")
                    .font(.caption)
                    .foregroundStyle(textColor),
                alignment: .bottomLeading
            )
            .overlay(
                Text("\(maxReps.formatted())x")
                    .font(.caption)
                    .foregroundStyle(textColor),
                alignment: .topLeading
            )
            .overlay(
                Text("\(minWeight.formatted())lbs")
                    .font(.caption)
                    .foregroundStyle(textColor),
                alignment: .bottomTrailing
            )
            .overlay(
                Text("\(maxWeight.formatted())lbs")
                    .font(.caption)
                    .foregroundStyle(textColor),
                alignment: .topTrailing
            )
            
            List {
                HStack {
                    Text("Date")
                        .frame(width: 100)
                    
                    Spacer()
                    
                    Text("Reps")
                        .frame(width: 100)
                    
                    Spacer()
                    
                    Text("Weight (lbs)")
                        .frame(width: 100)
                }
                
                let dateFormatter = DateFormatter()
                let _ = dateFormatter.dateFormat = "MM/dd/yyyy"
                
                ForEach(info, id: \.0) { log in
                    HStack {
                        Text(dateFormatter.string(from: Date(timeIntervalSince1970: log.2)))
                            .frame(width: 100)
                        
                        Spacer()
                        
                        Text(log.0.formatted())
                            .frame(width: 100)
                        
                        Spacer()
                        
                        Text(log.1.formatted())
                            .frame(width: 100)
                    }
                    .foregroundStyle(textColor)
                }
            }
        }
    }
    
    
    // Views
    var stats: some View {
        VStack {
            if showCharts {
                Text("Total Time: \(lengthToString(length: selectedTotalTime))")
                
                getMuscleGroupBreakdownChart()
            }
            
            if showGraph {
                if showCharts {
                    Divider()
                        .padding()
                }
                
                getGraph()
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .padding()
    }
}
