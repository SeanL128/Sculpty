//
//  SculptyApp.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData
import MijickPopups

@main
struct SculptyApp: App {
    @Environment(\.modelContext) private var context
    
    @StateObject private var settings = CloudSettings()
    
    var colorScheme: ColorScheme? {
        switch settings.appearance {
        case .light:
            return .light
        case .dark:
            return .dark
        case .automatic:
            return nil
        }
    }
    
    static var hasLaunched: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Main()
                .preferredColorScheme(colorScheme)
                .accentColor(Color("AccentColor"))
                .dynamicTypeSize(.medium ... .xxxLarge)
                .modelContainer(for: [Workout.self, Exercise.self, WorkoutLog.self, CaloriesLog.self, Measurement.self])
                .environmentObject(settings)
                .registerPopups(id: .shared) { config in config
                    .vertical { $0
                        .enableDragGesture(true)
                        .tapOutsideToDismissPopup(true)
                        .cornerRadius(15)
                        .popupTopPadding(10)
                    }
                    .center { $0
                        .tapOutsideToDismissPopup(true)
                        .backgroundColor(ColorManager.background)
                        .cornerRadius(15)
                        .popupHorizontalPadding(5)
                    }
                }
                .task {
                    if !SculptyApp.hasLaunched {
                        performAppLaunchTasks()
                        SculptyApp.hasLaunched = true
                    }
                }
        }
    }
    
    private func performAppLaunchTasks() {
        do {
            let workouts = try context.fetch(FetchDescriptor<Workout>())
            
            let invalidWorkouts = workouts.filter { $0.index < 0 }
            
            if !invalidWorkouts.isEmpty {
                for workout in invalidWorkouts {
                    workout.exercises.forEach { context.delete($0) }
                    context.delete(workout)
                }
                
                try context.save()
            }
            
            for workout in workouts {
                for exercise in workout.exercises {
                    if exercise.exercise == nil {
                        context.delete(exercise)
                        workout.exercises.remove(at: workout.exercises.firstIndex(of: exercise)!)
                    }
                }
            }
            
            try context.save()
        } catch {
            debugLog("Error: \(error.localizedDescription)")
        }
    }
}
