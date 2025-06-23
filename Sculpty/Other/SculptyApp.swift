//
//  SculptyApp.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct SculptyApp: App {
    @Environment(\.modelContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var settings = CloudSettings()
    
    static var hasLaunched: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Main()
                .accentColor(Color("AccentColor"))
                .dynamicTypeSize(.medium ... .xxxLarge)
                .modelContainer(for: [Workout.self, Exercise.self, WorkoutLog.self, CaloriesLog.self, Measurement.self])
                .environmentObject(settings)
                .task {
                    if !SculptyApp.hasLaunched {
                        performAppLaunchTasks()
                        SculptyApp.hasLaunched = true
                    }
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        UNUserNotificationCenter.current().setBadgeCount(0)
                    }
                }
        }
    }
    
    private func performAppLaunchTasks() {
        requestNotificationPermission()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NotificationManager.shared.scheduleAllNotifications()
        }
        
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
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                settings.enableNotifications = true
            } else {
                settings.enableNotifications = false
            }
        }
    }
}
