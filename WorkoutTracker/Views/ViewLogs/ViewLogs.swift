//
//  ViewLogs.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/26/25.
//

import SwiftUI
import SwiftData

struct ViewLogs: View {
    @Environment(\.modelContext) var context
    
    @Query var workouts: [Workout]
    @Query var workoutLogs: [WorkoutLog]
    
    private var validWorkouts: [Workout] {
        workouts.filter { workoutLogs.map { $0.workout.id }.contains($0.id) }
    }
    
    @State private var delete: (Bool, WorkoutLog) = (false, WorkoutLog(workout: Workout()))
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Logs")
                        .font(.largeTitle.bold())
                    
                    Spacer()
                }
                .padding()
                
                List {
                    ForEach(validWorkouts.sorted { $0.index < $1.index }) { workout in
                        Section {
                            ForEach(workoutLogs.filter { $0.workout.id == workout.id }) { log in
                                NavigationLink {
                                    ViewWorkoutLog(workoutLog: log)
                                } label: {
                                    Text(formatDate(Date(timeIntervalSince1970: log.start)))
                                }
                                .swipeActions {
                                    Button("Delete") {
                                        delete.0 = true
                                        delete.1 = log
                                    }
                                    .tint(.red)
                                }
                            }
                        } header: {
                            Text(workout.name)
                        }
                    }
                }
                .confirmationDialog("Delete \(delete.1.workout.name) log from \(formatDate(Date(timeIntervalSince1970: delete.1.start)))?", isPresented: $delete.0, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        if Calendar.current.isDate(Date(timeIntervalSince1970: delete.1.start), inSameDayAs: Date()) {
                            let newLog = WorkoutLog(workout: delete.1.workout)
                            context.insert(newLog)
                        }
                        
                        context.delete(delete.1)
                        
                        try? context.save()
                        
                        delete.0 = false
                        delete.1 = WorkoutLog(workout: Workout())
                    }
                }
            }
        }
    }
}

#Preview {
    ViewLogs()
}
