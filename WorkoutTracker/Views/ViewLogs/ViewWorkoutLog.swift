//
//  ViewWorkoutLog.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/26/25.
//

import SwiftUI

struct ViewWorkoutLog: View {
    @Environment(\.modelContext) var context
    
    private var workoutLog: WorkoutLog
    
    @State private var delete: (Bool, ExerciseLog) = (false, ExerciseLog(index: 0, exercise: WorkoutExercise()))
    
    init(workoutLog: WorkoutLog) {
        self.workoutLog = workoutLog
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(workoutLog.exerciseLogs.sorted { $0.exercise.index < $1.exercise.index }) { exerciseLog in
                        let setLogs = exerciseLog.setLogs.sorted { $0.start < $1.start }
                        if !(setLogs.filter { $0.completed }).isEmpty {
                            Section {
                                ForEach(setLogs.filter { $0.completed }) { setLog in
                                    Text("\(formatDateWithTime(Date(timeIntervalSince1970: setLog.start)))")
                                    .swipeActions {
                                        Button("Delete") {
                                            delete.0 = true
                                            delete.1 = exerciseLog
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
                .confirmationDialog("Delete log from \(formatDateWithTime(Date(timeIntervalSince1970: delete.1.start)))?", isPresented: $delete.0, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        workoutLog.exerciseLogs.removeAll { $0.id == delete.1.id }
                        
                        try? context.save()
                        
                        delete.0 = false
                        delete.1 = ExerciseLog(index: 0, exercise: WorkoutExercise())
                    }
                }
            }
        }
    }
}

#Preview {
    ViewWorkoutLog(workoutLog: WorkoutLog(workout: Workout()))
}
