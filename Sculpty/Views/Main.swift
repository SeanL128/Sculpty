//
//  Main.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/19/25.
//

import SwiftUI
import SwiftData

struct Main: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var settings: CloudSettings
    @StateObject private var popupManager = PopupManager.shared
    
    @State private var hasPerformedLaunchTasks = false
    
    var body: some View {
        ZStack {
            if !settings.onboarded {
                Onboarding()
                    .transition(
                        .asymmetric(
                            insertion: .identity,
                            removal: .opacity.combined(with: .scale(scale: 2))
                        )
                    )
                    .zIndex(1)
            }
            
            Home()
                .opacity(settings.onboarded ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: settings.onboarded)
            
            ForEach(Array(popupManager.popups.enumerated()), id: \.element.id) { index, popup in
                PopupOverlay(
                    popup: popup,
                    isLast: index == popupManager.popups.count - 1,
                    onDismiss: {
                        popupManager.dismiss(popup.id)
                    }
                )
                .zIndex(Double(index + 1000))
            }
        }
        .onChange(of: settings.onboarded) {
            withAnimation(.easeOut(duration: 0.5)) { }
        }
        .onAppear() {
            if !hasPerformedLaunchTasks {
                performAppLaunchTasks()
                hasPerformedLaunchTasks = true
            }
        }
    }
    
    private func performAppLaunchTasks() {
        requestNotificationPermission()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NotificationManager.shared.scheduleAllNotifications()
        }
        
        performDataCleanup()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    settings.enableNotifications = true
                } else {
                    settings.enableNotifications = false
                }
            }
        }
    }
    
    private func performDataCleanup() {
        do {
            let workouts = try context.fetch(FetchDescriptor<Workout>())
            for workout in workouts {
                if workout.index == -1 {
                    debugLog(workout.name)
                }
            }
            
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
            
            
            let logs = try context.fetch(FetchDescriptor<WorkoutLog>())
                .filter { ($0.started && !$0.completed && $0.start <= Date().addingTimeInterval(-86400)) }
            
            for log in logs {
                log.finishWorkout(date: log.start.addingTimeInterval(86400))
            }
            
            
            try context.save()
        } catch {
            debugLog("Error: \(error.localizedDescription)")
        }
    }
}
