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
    @StateObject private var toastManager = ToastManager.shared
    
    @State private var hasPerformedLaunchTasks = false
    
    @State private var showLaunchScreen = true

    var body: some View {
        ZStack {
            if showLaunchScreen {
                LaunchScreen {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLaunchScreen = false
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.8)),
                        removal: .opacity.combined(with: .scale(scale: 1.2))
                    )
                )
                .zIndex(2)
            }
            
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
                .zIndex(Double(index + 100))
            }
            
            ForEach(Array(toastManager.toasts.enumerated()), id: \.element.id) { index, toast in
                ToastOverlay(
                    toast: toast,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            toastManager.dismiss(toast.id)
                        }
                    }
                )
                .zIndex(Double(index + 200))
            }
        }
        .background(ColorManager.background)
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
            
            let invalidWorkouts = workouts.filter { workout in
                workout.index < 0 || workout.exercises.isEmpty || workout.exercises.allSatisfy { $0.exercise == nil }
            }
            
            if !invalidWorkouts.isEmpty {
                for workout in invalidWorkouts {
                    for exercise in workout.exercises {
                        context.delete(exercise)
                    }
                    
                    context.delete(workout)
                }
                
                try context.save()
            }
            
            for workout in workouts where !invalidWorkouts.contains(workout) {
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
                guard !log.exerciseLogs.filter({ !$0.setLogs.filter { $0.completed }.isEmpty }).isEmpty else {
                    for exerciseLog in log.exerciseLogs {
                        context.delete(exerciseLog)
                    }
                    
                    context.delete(log)
                    
                    continue
                }
                
                log.finishWorkout()
            }
            
            try context.save()
        } catch {
            debugLog("Error: \(error.localizedDescription)")
        }
    }
}
