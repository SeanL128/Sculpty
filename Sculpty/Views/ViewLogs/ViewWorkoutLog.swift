//
//  ViewWorkoutLog.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/26/25.
//

import SwiftUI

struct ViewWorkoutLog: View {
    @Environment(\.modelContext) var context
    @StateObject private var viewModel: WorkoutLogViewModel
    
    @State private var logToDelete: ExerciseLog? = nil
    
    init(workoutLog: WorkoutLog) {
        _viewModel = StateObject(wrappedValue: WorkoutLogViewModel(workoutLog: workoutLog))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    List {
                        ForEach(viewModel.exerciseLogs) { exerciseLog in
                            let setLogs = viewModel.completedSetLogs(for: exerciseLog)
                            if !setLogs.isEmpty {
                                Section {
                                    ForEach(setLogs) { setLog in
                                        Text("\(formatDateWithTime(setLog.start))")
                                            .swipeActions {
                                                Button("Delete") {
                                                    logToDelete = exerciseLog
                                                }
                                                .tint(.red)
                                            }
                                    }
                                } header: {
                                    Text(exerciseLog.exercise.exercise?.name ?? "")
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .confirmationDialog("Delete log?", isPresented: Binding(
                        get: { logToDelete != nil },
                        set: { if !$0 { logToDelete = nil } }
                    ), titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            if let log = logToDelete {
                                viewModel.deleteExerciseLog(log, context: context)
                                
                                logToDelete = nil
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ViewWorkoutLog(workoutLog: WorkoutLog(workout: Workout()))
}
