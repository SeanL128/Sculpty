//
//  ByWorkoutsStats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI
import SwiftData

struct ByWorkoutStats: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    @Query private var workoutLogs: [WorkoutLog]
    
    @State private var selectedRangeIndex: Int = 0
    @Binding var selectedTab: Int
    
    @Binding var workout: Workout?
    
    @Binding var exercise: Exercise?
    
    private var dataValues: [WorkoutLog] {
        workout?.workoutLogs ?? []
    }
    private var weightData: [(date: Date, value: Double)] {
        dataValues
            .map {
                (
                    date: $0.start,
                    value: $0.getTotalWeight(
                        settings.includeWarmUp,
                        settings.includeDropSet,
                        settings.includeCoolDown
                    )
                )
            }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var repsData: [(date: Date, value: Double)] {
        dataValues
            .map {
                (
                    date: $0.start,
                    value: Double(
                        $0.getTotalReps(
                            settings.includeWarmUp,
                            settings.includeDropSet,
                            settings.includeCoolDown
                        )
                    )
                )
            }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var distanceData: [(date: Date, value: Double)] {
        dataValues
            .map {
                (
                    date: $0.start,
                    value: $0.getTotalDistance(
                        settings.includeWarmUp,
                        settings.includeDropSet,
                        settings.includeCoolDown
                    )
                )
            }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var timeData: [(date: Date, value: Double)] {
        dataValues
            .map {
                (
                    date: $0.start,
                    value: round(
                        (
                            $0.getTotalTime(
                                settings.includeWarmUp,
                                settings.includeDropSet,
                                settings.includeCoolDown
                            ) / 60
                        ),
                        2
                    )
                )
            }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    private var durationData: [(date: Date, value: Double)] {
        dataValues
            .map { (date: $0.start, value: round(($0.getLength() / 60), 2)) }
            .filter { $0.value > 0 }
            .sorted { $0.date < $1.date }
    }
    
    private var showWeightData: Bool { !weightData.isEmpty || !repsData.isEmpty }
    private var showDistanceData: Bool { !distanceData.isEmpty || !timeData.isEmpty }
    private var showDurationData: Bool { !durationData.isEmpty }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingL) {
            NavigationLink {
                SelectWorkout(selectedWorkout: $workout)
            } label: {
                HStack(alignment: .center, spacing: .spacingXS) {
                    Text(workout?.name ?? "Select Workout")
                        .bodyText(weight: .regular)
                    
                    Image(systemName: "chevron.right")
                        .bodyImage()
                }
            }
            .textColor()
            .animatedButton()
            
            ChartDateRangeControl(selectedRangeIndex: $selectedRangeIndex)
            
            if showWeightData || showDistanceData || showDurationData {
                ScrollView {
                    VStack(alignment: .leading, spacing: .spacingL) {
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
                        
                        if showDurationData {
                            Text("TOTAL WORKOUT DURATION")
                                .subheadingText()
                                .textColor()
                                .padding(.bottom, -16)
                            
                            LineChart(selectedRangeIndex: $selectedRangeIndex, data: durationData, units: "min")
                        }
                        
                        if let workout = workout,
                           !workout.exercises.isEmpty {
                            let exercises = workout.exercises
                                .filter { !($0.exercise?.hidden ?? true) }
                                .sorted(by: { $0.index < $1.index })
                                .compactMap({ $0.exercise }).removingDuplicates()
                            
                            VStack(alignment: .leading, spacing: .spacingXS) {
                                Text("EXERCISES")
                                    .subheadingText()
                                    .textColor()
                                
                                VStack(alignment: .leading, spacing: .listSpacing) {
                                    ForEach(exercises, id: \.id) { exercise in
                                        Button {
                                            self.exercise = exercise
                                            
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                selectedTab = 2
                                            }
                                        } label: {
                                            HStack(alignment: .center, spacing: .spacingXS) {
                                                Text(exercise.name)
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
                }
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity)
            } else {
                EmptyState(
                    image: "dumbbell",
                    text: "No data found\(workout != nil ? " for \(workout?.name ?? "this workout")" : "")",
                    subtext: "Try selecting a \(workout != nil ? "different" : "") workout"
                )
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showWeightData)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showDistanceData)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showDurationData)
    }
}
