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
        ContainerView(title: log.workout?.name ?? "Workout") {
            Text(formatDate(log.start))
                .bodyText(size: 20, weight: .bold)
                .textColor()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Time: \(lengthToString(length: log.getLength()))")
                    .bodyText(size: 16)
                    .textColor()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: log.getLength())
                
                Text("Total Reps: \(reps) reps")
                    .bodyText(size: 16)
                    .textColor()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: reps)
                
                Text("Total Weight: \(weight)\(UnitsManager.weight)")
                    .bodyText(size: 16)
                    .textColor()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: weight)
                
                Spacer()
                    .frame(height: 5)
                
                MuscleGroupDisplay(groups: muscleGroups)
            }
            
            Spacer()
                .frame(height: 5)
            
            ForEach(log.exerciseLogs.sorted { $0.index < $1.index }, id: \.id) { exerciseLog in
                ExerciseLogGroup(exerciseLog: exerciseLog, workoutLog: log)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    ))
            }
            .animation(.easeInOut(duration: 0.3), value: log.exerciseLogs.count)
        }
    }
}
