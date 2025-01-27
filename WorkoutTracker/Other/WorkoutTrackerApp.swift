//
//  WorkoutTrackerApp.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData

@main
struct WorkoutTrackerApp: App {
    @Environment(\.modelContext) private var context
    
    init() {
        let container = try! ModelContainer(for: Workout.self, Exercise.self, WorkoutLog.self)
        preloadData(context: container.mainContext)
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [Workout.self, Exercise.self, WorkoutLog.self])
        }
    }
    
    private func preloadData(context: ModelContext) {
        let fetchRequest = FetchDescriptor<Exercise>()
        if let existingExercises = try? context.fetch(fetchRequest), existingExercises.isEmpty {
            for exercise in defaultExercises {
                context.insert(exercise)
            }
            
            do {
                try context.save()
            } catch {
                print("Error preloading data: \(error)")
            }
        }
    }
}
