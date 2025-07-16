//
//  PerformWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/22/25.
//

import SwiftUI
import SwiftData

struct PerformWorkout: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let log: WorkoutLog
    
    @StateObject private var restTimer: RestTimer = RestTimer()
    
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
                                        exerciseLog.setLogs.forEach { context.delete($0) }
                                        
                                        context.delete(exerciseLog)
                                    }
                                    
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
                    
                    TabView {
                        ForEach(log.exerciseLogs.sorted { $0.index < $1.index }, id: \.id) { exerciseLog in
                            PerformExercise(workoutLog: log, exerciseLog: exerciseLog, restTimer: restTimer)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rest Time: \(restTimer.timeString())")
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: restTimer.timeString())
                        
                        Text("Total Time: \(timeIntervalToString(totalTime))")
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: totalTime)
                    }
                    .statsText(size: 16)
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
            }
            .onDisappear {
                totalTimer?.invalidate()
                totalTimer = nil
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
