//
//  ByExerciseStats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI
import SwiftData

struct ByExerciseStats: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    @Query private var workoutLogs: [WorkoutLog]
    @Query private var exerciseLogs: [ExerciseLog]
    
    @State private var selectedRangeIndex: Int = 0
    @Binding var selectedTab: Int
    
    @Binding var exercise: Exercise?
    
    @Binding var workout: Workout?
    
    private var dataValues: [WorkoutLog] {
        workoutLogs.filter { $0.exerciseLogs.contains(where: { $0.exercise?.exercise?.id == exercise?.id }) }
    }
    private var prData: [(date: Date, value: Double)] {
        guard let exerciseId = exercise?.id else { return [] }
        
        var pr: Double = 0
        var prData: [(date: Date, value: Double)] = []
        
        for log in exerciseLogs.filter({ $0.exercise?.exercise?.id == exerciseId }) {
            let max = log.setLogs
                .compactMap {
                    if let weight = $0.weight,
                       let reps = $0.reps {
                        return weight / Double(reps) / Double(reps)
                    } else {
                        return nil
                    }
                }
                .max() ?? 0
            
            if max > pr {
                pr = max
                prData.append((date: log.start, value: pr))
            }
        }
        
        prData.append((date: Date(), value: pr))
        
        return prData
    }
    private var oneRmData: [(date: Date, value: Double)] {
        guard settings.show1RM,
              let exerciseId = exercise?.id else { return [] }
        
        return dataValues
            .map {
                (
                    date: $0.start,
                    value: $0.exerciseLogs
                        .filter {
                            $0.exercise?.exercise?.id == exerciseId
                        }
                        .map { $0.getMaxOneRM() }
                        .max() ?? 0
                )
            }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var weightData: [(date: Date, value: Double)] {
        guard let exerciseId = exercise?.id else { return [] }
        
        return dataValues
            .map {
                (
                    date: $0.start,
                    value: $0.exerciseLogs
                        .filter {
                            $0.exercise?.exercise?.id == exerciseId
                        }
                        .reduce(0) {
                            $0 + $1.getTotalWeight(
                                settings.includeWarmUp,
                                settings.includeDropSet,
                                settings.includeCoolDown
                            )
                        }
                )
            }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var repsData: [(date: Date, value: Double)] {
        guard let exerciseId = exercise?.id else { return [] }
        
        return dataValues
            .map {
                (
                    date: $0.start,
                    value: Double(
                        $0.exerciseLogs
                            .filter {
                                $0.exercise?.exercise?.id == exerciseId
                            }
                            .reduce(0) {
                                $0 + $1.getTotalReps(
                                    settings.includeWarmUp,
                                    settings.includeDropSet,
                                    settings.includeCoolDown
                                )
                            }
                    )
                )
            }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var distanceData: [(date: Date, value: Double)] {
        guard let exerciseId = exercise?.id else { return [] }
        
        return dataValues
            .map {
                (
                    date: $0.start,
                    value: $0.exerciseLogs
                        .filter {
                            $0.exercise?.exercise?.id == exerciseId
                        }
                        .reduce(0) {
                            $0 + $1.getTotalDistance(
                                settings.includeWarmUp,
                                settings.includeDropSet,
                                settings.includeCoolDown
                            )
                        }
                )
            }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var timeData: [(date: Date, value: Double)] {
        guard let exerciseId = exercise?.id else { return [] }
        
        return dataValues
            .map {
                (
                    date: $0.start,
                    value: round(
                        (
                            $0.exerciseLogs
                                .filter {
                                    $0.exercise?.exercise?.id == exerciseId
                                }
                                .reduce(0) {
                                    $0 + $1.getTotalTime(
                                        settings.includeWarmUp,
                                        settings.includeDropSet,
                                        settings.includeCoolDown
                                    )
                                }
                        ) / 60,
                        2
                    )
                )
            }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    
    private var showPrData: Bool { !prData.isEmpty }
    private var showOneRmData: Bool { !oneRmData.isEmpty }
    private var showWeightData: Bool { !weightData.isEmpty || !repsData.isEmpty }
    private var showDistanceData: Bool { !distanceData.isEmpty || !timeData.isEmpty }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingL) {
            NavigationLink {
                SelectExercise(selectedExercise: $exercise, forStats: true)
            } label: {
                HStack(alignment: .center, spacing: .spacingXS) {
                    Text(exercise?.name ?? "Select Exercise")
                        .subheadingText(weight: .medium)
                    
                    Image(systemName: "chevron.right")
                        .subheadingImage()
                }
            }
            .textColor()
            .animatedButton(feedback: .selection)
            .animation(.easeInOut(duration: 0.3), value: exercise?.name)
            
            ChartDateRangeControl(selectedRangeIndex: $selectedRangeIndex)
            
            if showPrData || showOneRmData || showWeightData || showDistanceData {
                ScrollView {
                    VStack(alignment: .leading, spacing: .spacingL) {
                        if showPrData {
                            // PR
                            VStack(alignment: .leading, spacing: .spacingXS) {
                                Text("PR")
                                    .subheadingText()
                                    .textColor()
                                
                                Text("Current PR: \(prData.last?.value.formatted() ?? "0")\(UnitsManager.weight) (\(formatDate(prData.last?.date ?? Date())))") // swiftlint:disable:this line_length
                                    .bodyText()
                                    .textColor()
                                    .monospacedDigit()
                            }
                        }
                        
                        if showOneRmData {
                            // 1RM
                            VStack(alignment: .leading, spacing: .spacingXS) {
                                Text("ONE REP MAX (1RM)")
                                    .subheadingText()
                                    .textColor()
                                
                                LineChart(
                                    selectedRangeIndex: $selectedRangeIndex,
                                    data: oneRmData,
                                    units: UnitsManager.weight
                                )
                            }
                        }
                        
                        if showWeightData {
                            // Weight
                            VStack(alignment: .leading, spacing: .spacingXS) {
                                Text("TOTAL WEIGHT")
                                    .subheadingText()
                                    .textColor()
                                
                                LineChart(
                                    selectedRangeIndex: $selectedRangeIndex,
                                    data: weightData,
                                    units: UnitsManager.weight
                                )
                            }
                            
                            // Reps
                            VStack(alignment: .leading, spacing: .spacingXS) {
                                Text("TOTAL REPS")
                                    .subheadingText()
                                    .textColor()
                                
                                LineChart(selectedRangeIndex: $selectedRangeIndex, data: repsData, units: "reps")
                            }
                        }
                        
                        if showDistanceData {
                            // Distance
                            VStack(alignment: .leading, spacing: .spacingXS) {
                                Text("TOTAL DISTANCE")
                                    .subheadingText()
                                    .textColor()
                                
                                LineChart(
                                    selectedRangeIndex: $selectedRangeIndex,
                                    data: distanceData,
                                    units: UnitsManager.longLength
                                )
                            }
                            
                            // Time (Cardio)
                            VStack(alignment: .leading, spacing: .spacingXS) {
                                Text("TOTAL CARDIO TIME")
                                    .subheadingText()
                                    .textColor()
                                
                                LineChart(selectedRangeIndex: $selectedRangeIndex, data: timeData, units: "min")
                            }
                        }
                        
                        if let workouts = exercise?.workoutExercises
                            .compactMap({ $0.workout })
                            .filter({ !$0.hidden })
                            .removingDuplicates(),
                           !workouts.isEmpty {
                            VStack(alignment: .leading, spacing: .spacingXS) {
                                Text("WORKOUTS")
                                    .subheadingText()
                                    .textColor()
                                
                                VStack(alignment: .leading, spacing: .listSpacing) {
                                    ForEach(workouts, id: \.id) { workout in
                                        Button {
                                            self.workout = workout
                                            
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                selectedTab = 2
                                            }
                                        } label: {
                                            HStack(alignment: .center, spacing: .spacingXS) {
                                                Text(workout.name)
                                                    .bodyText(weight: .regular)
                                                
                                                Image(systemName: "chevron.right")
                                                    .bodyImage()
                                            }
                                        }
                                        .textColor()
                                        .animatedButton(feedback: .selection)
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .leading)),
                                            removal: .opacity.combined(with: .move(edge: .trailing))
                                        ))
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity)
            } else {
                EmptyState(
                    image: "dumbbell",
                    text: "No data found\(exercise != nil ? " for \(exercise?.name ?? "this exercise")" : "")",
                    subtext: "Try selecting \(exercise != nil ? "a different" : "an") exercise"
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showPrData)
        .animation(.easeInOut(duration: 0.3), value: showOneRmData)
        .animation(.easeInOut(duration: 0.3), value: showWeightData)
        .animation(.easeInOut(duration: 0.3), value: showDistanceData)
    }
}
