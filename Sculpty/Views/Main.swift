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
                            insertion: .opacity.combined(with: .scale(scale: 0.8)),
                            removal: .opacity.combined(with: .scale(scale: 1.2)).combined(with: .move(edge: .top))
                        )
                    )
                    .zIndex(1)
            }
            
            Home()
                .opacity(settings.onboarded ? 1 : 0)
                .scaleEffect(settings.onboarded ? 1.0 : 0.95)
                .animation(.easeInOut(duration: 0.6).delay(settings.onboarded ? 0.3 : 0), value: settings.onboarded)
            
            ForEach(Array(popupManager.popups.enumerated()), id: \.element.id) { index, popup in
                PopupOverlay(
                    popup: popup,
                    isLast: index == popupManager.popups.count - 1,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            popupManager.dismiss(popup.id)
                        }
                    }
                )
                .zIndex(Double(index + 1000))
            }
        }
        .onAppear {
            if !hasPerformedLaunchTasks {
                performAppLaunchTasks()
                
                hasPerformedLaunchTasks = true
            }
        }
        .onChange(of: settings.onboarded) { _, newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) { }
            }
        }
    }
    
    private func performAppLaunchTasks() {
        requestNotificationPermission()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NotificationManager.shared.scheduleAllNotifications()
        }
        
        Task {
            await MainActor.run {
                performDataCleanup()
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
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
            for workout in workouts where workout.index == -1 {
                debugLog(workout.name)
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
                for exercise in workout.exercises where exercise.exercise == nil {
                    context.delete(exercise)
                    
                    if let index = workout.exercises.firstIndex(of: exercise) {
                        workout.exercises.remove(at: index)
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
