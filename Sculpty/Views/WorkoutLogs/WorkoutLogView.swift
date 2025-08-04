//
//  WorkoutLogView.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/26/25.
//

import SwiftUI
import SwiftData

struct WorkoutLogView: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var settings: CloudSettings
    
    private let log: WorkoutLog
    private let muscleGroups: [MuscleGroup]
    
    private var time: String { lengthToString(length: log.getLength()) }
    // swiftlint:disable line_length
    private var reps: String { "\(log.getTotalReps(settings.includeWarmUp, settings.includeDropSet, settings.includeCoolDown))" }
    private var weight: String { log.getTotalWeight(settings.includeWarmUp, settings.includeDropSet, settings.includeCoolDown).formatted() }
    // swiftlint:enable line_length
    
    init(log: WorkoutLog) {
        self.log = log
        muscleGroups = log.getMuscleGroupBreakdown()
    }
    
    var body: some View {
        ContainerView(title: log.workout?.name ?? "Workout", spacing: .spacingXL) {
            VStack(alignment: .leading, spacing: .spacingL) {
                Text(formatDate(log.start))
                    .headingText()
                    .textColor()
                
                VStack(alignment: .leading, spacing: .spacingS) {
                    Text("Total Time: \(lengthToString(length: log.getLength()))")
                        .bodyText()
                        .textColor()
                        .monospacedDigit()
                    
                    Text("Total Reps: \(reps) reps")
                        .bodyText()
                        .textColor()
                        .monospacedDigit()
                    
                    Text("Total Weight: \(weight)\(UnitsManager.weight)")
                        .bodyText()
                        .textColor()
                        .monospacedDigit()
                }
                
                if !muscleGroups.isEmpty {
                    MuscleGroupDisplay(groups: muscleGroups)
                }
            }
            
            VStack(alignment: .leading, spacing: .spacingXL) {
                ForEach(log.exerciseLogs.sorted { $0.index < $1.index }, id: \.id) { exerciseLog in
                    ExerciseLogGroup(exerciseLog: exerciseLog, workoutLog: log)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                }
                .animation(.easeInOut(duration: 0.3), value: log.exerciseLogs)
            }
        }
    }
}
