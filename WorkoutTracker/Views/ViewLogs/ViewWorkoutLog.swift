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
                        Section {
                            ForEach(exerciseLog.setLogs.sorted { $0.start < $1.start }) { setLog in
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
                .confirmationDialog("Are you sure?", isPresented: $delete.0) {
                    Button("Delete log from \(formatDateWithTime(Date(timeIntervalSince1970: delete.1.start)))?", role: .destructive) {
                        context.delete(delete.1)
                        
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
