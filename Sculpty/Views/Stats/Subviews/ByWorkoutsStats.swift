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
        VStack(alignment: .leading, spacing: 20) {
            NavigationLink {
                SelectWorkout(selectedWorkout: $workout, forStats: true)
            } label: {
                HStack(alignment: .center) {
                    Text(workout?.name ?? "Select Workout")
                        .bodyText(size: 20, weight: .bold)
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 14, weight: .bold))
                }
            }
            .textColor()
            .animatedButton(scale: 0.98)
            
            ChartDateRangeControl(selectedRangeIndex: $selectedRangeIndex)
            
            if showWeightData || showDistanceData || showDurationData {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if showWeightData {
                            // Weight
                            Text("TOTAL WEIGHT")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            LineChart(
                                selectedRangeIndex: $selectedRangeIndex,
                                data: weightData,
                                units: UnitsManager.weight
                            )
                            
                            // Reps
                            Text("TOTAL REPS")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            LineChart(selectedRangeIndex: $selectedRangeIndex, data: repsData, units: "reps")
                        }
                        
                        if showDistanceData {
                            // Distance
                            Text("TOTAL DISTANCE")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            LineChart(
                                selectedRangeIndex: $selectedRangeIndex,
                                data: distanceData,
                                units: UnitsManager.longLength
                            )
                            
                            // Time (Cardio)
                            Text("TOTAL CARDIO TIME")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            LineChart(selectedRangeIndex: $selectedRangeIndex, data: timeData, units: "min")
                        }
                        
                        if showDurationData {
                            Text("TOTAL WORKOUT DURATION")
                                .headingText(size: 24)
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
                            
                            Text("EXERCISES")
                                .headingText(size: 24)
                                .textColor()
                                .padding(.bottom, -16)
                            
                            VStack(alignment: .leading, spacing: 9) {
                                ForEach(exercises, id: \.id) { exercise in
                                    Button {
                                        self.exercise = exercise
                                        
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedTab = 2
                                        }
                                    } label: {
                                        HStack(alignment: .center) {
                                            Text(exercise.name)
                                                .bodyText(size: 18, weight: .bold)
                                            
                                            Image(systemName: "chevron.right")
                                                .padding(.leading, -2)
                                                .font(Font.system(size: 12))
                                        }
                                    }
                                    .textColor()
                                    .animatedButton(scale: 0.98, feedback: .selection)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .move(edge: .leading)),
                                        removal: .opacity.combined(with: .move(edge: .trailing))
                                    ))
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
                    message: "No Data",
                    size: 18
                )
            }
        }
    }
}
