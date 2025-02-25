//
//  ViewLogs.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/26/25.
//

import SwiftUI
import SwiftData

struct ViewLogs: View {
    @Environment(\.modelContext) var context
    
    @Query(sort: \Workout.index) private var workouts: [Workout]
    @Query(filter: #Predicate<WorkoutLog> { $0.started }, sort: \WorkoutLog.start) private var workoutLogs: [WorkoutLog]

    private var validWorkouts: [Workout] {
        workouts.filter { workout in
            workoutLogs.contains { $0.workout.id == workout.id }
        }
    }
    
    private var logsByWorkout: [UUID: [WorkoutLog]] {
        Dictionary(grouping: workoutLogs, by: { $0.workout.id })
    }
    
    @State private var logToDelete: WorkoutLog? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    HStack {
                        Text("Logs")
                            .font(.largeTitle.bold())
                        
                        Spacer()
                    }
                    .padding()
                    
                    List {
                        ForEach(validWorkouts) { workout in
                            if let logs = logsByWorkout[workout.id] {
                                Section {
                                    ForEach(logs) { log in
                                        NavigationLink(destination: ViewWorkoutLog(workoutLog: log)) {
                                            Text(formatDate(log.start))
                                        }
                                        .swipeActions {
                                            Button("Delete") {
                                                logToDelete = nil
                                            }
                                            .tint(.red)
                                        }
                                    }
                                } header: {
                                    Text(workout.name)
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
                                if Calendar.current.isDate(log.start, inSameDayAs: Date()) {
                                    let newLog = WorkoutLog(workout: log.workout)
                                    context.insert(newLog)
                                }
                                
                                context.delete(log)
                                
                                try? context.save()
                                
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
    ViewLogs()
}
