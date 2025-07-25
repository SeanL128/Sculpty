//
//  PerformWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/22/25.
//

import SwiftUI
import SwiftData
import ActivityKit

struct PerformWorkout: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let log: WorkoutLog
    
    @StateObject private var restTimer: RestTimer = RestTimer()
    
    @StateObject private var activityManager = WorkoutActivityManager.shared
    @State private var activityUpdateTimer: Timer?
    
    @State private var totalTimer: Timer?
    @State private var totalTime: Double
    
    @State private var finishWorkoutSelection: Bool = false
    @State private var confirmDelete: Bool = false
    
    private var allLogsDone: Bool {
        guard !log.completed else { return true }
        
        if log.exerciseLogs.contains(where: { $0.setLogs.contains(where: { !($0.completed || $0.skipped) })}) {
            return false
        }
        
        return true
    }
    
    private var sortedExerciseLogs: [ExerciseLog] {
        log.exerciseLogs.sorted { $0.index < $1.index }
    }
    
    init(log: WorkoutLog) {
        self.log = log
        
        totalTime = log.getLength()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack(alignment: .leading, spacing: 12) {
                    ContainerViewHeader(title: log.workout?.name ?? "Workout", trailingItems: {
                        Button {
                            Popup.show(content: {
                                ConfirmationPopup(
                                    selection: $confirmDelete,
                                    promptText: "Delete \(log.workout?.name ?? "Workout") Log?",
                                    resultText: "This cannot be undone. This log will not be included in your stats.",
                                    cancelText: "Cancel",
                                    confirmText: "Delete"
                                )
                            })
                        } label: {
                            Image(systemName: "xmark")
                                .padding(.horizontal, 5)
                                .font(Font.system(size: 20))
                        }
                        .textColor()
                        .animatedButton(feedback: .warning)
                        .onChange(of: confirmDelete) {
                            if confirmDelete {
                                totalTimer?.invalidate()
                                totalTimer = nil
                                
                                do {
                                    log.completed = true
                                    
                                    try context.save()
                                    
                                    for exerciseLog in log.exerciseLogs {
                                        for setLog in exerciseLog.setLogs {
                                            context.delete(setLog)
                                        }
                                        
                                        try context.save()
                                        
                                        context.delete(exerciseLog)
                                    }
                                    
                                    try context.save()
                                    
                                    context.delete(log)
                                    
                                    try context.save()
                                    
                                    dismiss()
                                } catch {
                                    debugLog("Error: \(error.localizedDescription)")
                                }
                            }
                        }
                        
                        Button {
                            if log.completed {
                                Popup.show(content: {
                                    WorkoutSummaryPopup(log: log)
                                })
                            } else {
                                Popup.show(content: {
                                    ConfirmationPopup(
                                        selection: $finishWorkoutSelection,
                                        promptText: "Finish \(log.workout?.name ?? "Workout")?",
                                        resultText: "This will skip all remaining sets.",
                                        cancelText: "Cancel",
                                        confirmText: "Finish"
                                    )
                                })
                            }
                        } label: {
                            Image(systemName: log.completed ? "checkmark.circle.fill" : "checkmark.circle")
                                .padding(.horizontal, 5)
                                .font(Font.system(size: 20))
                        }
                        .textColor()
                        .animatedButton(feedback: .warning)
                        .animation(.easeInOut(duration: 0.3), value: log.completed)
                    })
                    
                    ProgressView(value: log.getProgress())
                        .padding(.horizontal)
                        .frame(height: 5)
                        .progressViewStyle(.linear)
                        .accentColor(ColorManager.text)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Spacer()
                        .frame(height: 0)
                    
                    TabView {
                        ForEach(sortedExerciseLogs, id: \.id) { exerciseLog in
                            VStack {
                                PerformExercise(workoutLog: log, exerciseLog: exerciseLog, restTimer: restTimer)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 0) {
                            Text("Rest Time: ")
                                .bodyText(size: 16)
                            
                            Text(restTimer.timeString())
                                .statsText(size: 16)
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .animation(.easeInOut(duration: 0.2), value: restTimer.timeString())
                        }
                        
                        HStack(spacing: 0) {
                            Text("Total Time: ")
                                .bodyText(size: 16)
                            
                            Text(timeIntervalToString(totalTime))
                                .statsText(size: 16)
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .animation(.easeInOut(duration: 0.2), value: totalTime)
                        }
                    }
                    .secondaryColor()
                }
                .padding()
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                totalTime = log.getLength()
                
                totalTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    totalTime = log.getLength()
                }
                
                activityManager.registerActiveWorkout(log)
                
                if !activityManager.hasActiveLiveActivity {
                    activityManager.startWorkoutActivity(for: log)
                }
                
                activityUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    activityManager.updateWorkoutActivity(for: log)
                }
                
                NotificationManager.shared.requestPermissionIfNeeded { granted in
                    DispatchQueue.main.async {
                        if !granted {
                            Popup.show(content: {
                                InfoPopup(
                                    title: "Enable Notifications",
                                    text: "To receive rest time reminders, please enable notifications in Settings > Sculpty > Notifications" // swiftlint:disable:this line_length
                                )
                            })
                        }
                    }
                }
            }
            .onDisappear {
                totalTimer?.invalidate()
                totalTimer = nil
                
                activityUpdateTimer?.invalidate()
                activityUpdateTimer = nil
                
                activityManager.removeActiveWorkout(log.id.uuidString)
            }
            .onChange(of: allLogsDone) {
                if allLogsDone && !log.completed {
                    let workoutName = log.workout?.name ?? "Workout"
                    
                    Task {
                        try? await Task.sleep(nanoseconds: 700_000_000)
                        
                        guard !log.completed else { return }
                        
                        Popup.show(content: {
                            ConfirmationPopup(
                                selection: $finishWorkoutSelection,
                                promptText: "Finish \(workoutName)?",
                                cancelText: "Continue",
                                confirmText: "Finish"
                            )
                        })
                    }
                    
                    activityManager.endWorkoutActivity(for: log)
                }
            }
            .onChange(of: finishWorkoutSelection) {
                if finishWorkoutSelection {
                    log.finishWorkout()
                    
                    do {
                        try context.save()
                    } catch {
                        debugLog("Error: \(error.localizedDescription)")
                    }
                    
                    Popup.dismissLast()
                    
                    Popup.show(content: {
                        WorkoutSummaryPopup(log: log)
                    })
                    
                    activityManager.endCurrentActivity()
                }
            }
        }
    }
    
    private func timeIntervalToString(_ time: Double) -> String {
        let interval = Int(time)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
