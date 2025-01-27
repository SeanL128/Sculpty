//
//  ContentView.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) var context
    
    @Query var workouts: [Workout]
    
    @State var deleteExercise: (Bool, Exercise) = (false, Exercise())
    @State var deleteWorkout: (Bool, Workout) = (false, Workout())
    
    @State private var showViewWorkout: Bool = false
    @State private var selectedWorkout: Workout?
    @State private var selectedLog: WorkoutLog?
    
    var body: some View {
        if showViewWorkout, let workout = selectedWorkout, let log = selectedLog {
            ViewWorkout(workout: workout, workoutLog: log, onBack: {
                showViewWorkout = false
            })
            .transition(.move(edge: .trailing))
        } else {
            TabView {
                WorkoutList { workout, log in
                    selectedWorkout = workout
                    selectedLog = log
                    showViewWorkout = true
                }
                .tabItem {
                    Label("Workouts", systemImage: "figure.run")
                }
                
                ExerciseList()
                    .tabItem {
                        Label("Exercises", systemImage: "dumbbell.fill")
                    }
                
                Stats()
                    .tabItem {
                        Label("Stats", systemImage: "chart.xyaxis.line")
                    }
                
                ViewLogs()
                    .tabItem {
                        Label("Logs", systemImage: "list.bullet.clipboard.fill")
                    }
                
                Options()
                    .tabItem {
                        Label("Options", systemImage: "gearshape.fill")
                    }
            }
            .onAppear {
                initWorkoutLogs()
            }
            .transition(.move(edge: .leading))
        }
    }
    
    func initWorkoutLogs() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastChecked = UserDefaults.standard.object(forKey: "lastCheckedDate") as? Date

        if lastChecked == nil || !Calendar.current.isDate(lastChecked!, inSameDayAs: today) {
            UserDefaults.standard.set(today, forKey: "lastCheckedDate")

            let workoutLogs: [WorkoutLog] = try! context.fetch(FetchDescriptor<WorkoutLog>())
            
            for log in workoutLogs {
                if !log.started {
                    context.delete(log)
                }
            }
            
            try? context.save()
            
            let existingLogs = workoutLogs.filter { log in
                Calendar.current.isDate(Date(timeIntervalSince1970: log.start), inSameDayAs: today)
            }

            if existingLogs.isEmpty {
                for workout in workouts {
                    let newLog = WorkoutLog(workout: workout)
                    context.insert(newLog)
                }

                try? context.save()
            }
        }
    }
}

#Preview {
    MainView()
}
