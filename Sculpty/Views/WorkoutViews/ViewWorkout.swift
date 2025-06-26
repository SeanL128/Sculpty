//
//  ViewWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/22/25.
//

import SwiftUI
import SwiftData
import MijickTimer

struct ViewWorkout: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var settings: CloudSettings
    
    @State private var log: WorkoutLog
    @State private var exercises: [WorkoutExercise]
    @State private var exerciseLogs: [ExerciseLog]
    
    private let restTimer: MTimer
    @State private var restTime: MTime = .init()
    
    @State private var totalTimer: Timer?
    @State private var totalTime: Double
    
    @State private var finishWorkoutSelection: Bool = false
    @State private var confirmDelete: Bool = false
    
    private var allLogsDone: Bool {
        for exerciseLog in log.exerciseLogs {
            for setLog in exerciseLog.setLogs {
                if !(setLog.completed || setLog.skipped) {
                    return false
                }
            }
        }
        
        return true
    }
    
    init(log: WorkoutLog) {
        self.log = log
        
        exercises = log.exerciseLogs.sorted { $0.index < $1.index }.compactMap { $0.exercise }
        exerciseLogs = log.exerciseLogs.sorted { $0.index < $1.index }
        
        restTimer = MTimer(MTimerID(rawValue: "Rest Timer \(log.id)"))
        
        totalTime = log.getLength()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding(.trailing, 6)
                                .font(Font.system(size: 22))
                        }
                        .textColor()
                        
                        Text(log.workout?.name ?? "Workout")
                            .headingText(size: 32)
                            .textColor()
                        
                        Spacer()
                        
                        Button {
                            Popup.show(content: {
                                ConfirmationPopup(selection: $confirmDelete, promptText: "Delete \(log.workout?.name ?? "Workout") Log?", resultText: "This cannot be undone. This log will not be included in your stats.", cancelText: "Cancel", confirmText: "Delete")
                            })
                        } label: {
                            Image(systemName: "xmark")
                                .padding(.horizontal, 5)
                                .font(Font.system(size: 20))
                        }
                        .textColor()
                        .onChange(of: confirmDelete) {
                            if confirmDelete {
                                log.completed = true
                                
                                do {
                                    for exerciseLog in log.exerciseLogs {
                                        for setLog in exerciseLog.setLogs {
                                            context.delete(setLog)
                                        }
                                        
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
                                    ConfirmationPopup(selection: $finishWorkoutSelection, promptText: "Finish \(log.workout?.name ?? "Workout")?", resultText: "This will skip all remaining sets.", cancelText: "Cancel", confirmText: "Finish")
                                })
                            }
                        } label: {
                            Image(systemName: log.completed ? "checkmark.circle.fill" : "checkmark.circle")
                                .padding(.horizontal, 5)
                                .font(Font.system(size: 20))
                        }
                        .textColor()
                    }
                    .padding(.bottom)
                    
                    TabView {
                        ForEach(log.exerciseLogs.sorted { $0.index < $1.index }, id: \.id) { exerciseLog in
                            if let exercise = exerciseLog.exercise {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 12) {
                                        VStack(alignment: .leading) {
                                            Text(exercise.exercise?.name ?? "Exercise \(exercise.index + 1)")
                                                .bodyText(size: 18, weight: .bold)
                                                .textColor()
                                            
                                            if settings.showTempo {
                                                let tempoArr = Array(exercise.tempo)
                                                
                                                Button {
                                                    Popup.show(content: {
                                                        TempoPopup(tempo: exercise.tempo)
                                                    })
                                                } label: {
                                                    HStack(alignment: .center) {
                                                        Text("Tempo: \(tempoArr[0])\(tempoArr[1])\(tempoArr[2])\(tempoArr[3])")
                                                            .bodyText(size: 14)
                                                        
                                                        Image(systemName: "chevron.right")
                                                            .padding(.leading, -2)
                                                            .font(Font.system(size: 8))
                                                    }
                                                }
                                                .textColor()
                                            }
                                            
                                            if !exercise.specNotes.isEmpty {
                                                Button {
                                                    Popup.show(content: {
                                                        InfoPopup(title: "\(exercise.exercise?.name ?? "Exercise") Notes", text: exercise.specNotes)
                                                    })
                                                } label: {
                                                    HStack(alignment: .center) {
                                                        Text("Notes")
                                                            .bodyText(size: 14)
                                                        
                                                        Image(systemName: "chevron.right")
                                                            .padding(.leading, -2)
                                                            .font(Font.system(size: 8))
                                                    }
                                                }
                                                .textColor()
                                            }
                                        }
                                        .padding(.bottom, 6)
                                        
                                        let maxIndex = exerciseLog.setLogs.map { $0.index }.max() ?? 0
                                        
                                        ForEach(exerciseLog.setLogs.sorted { $0.index < $1.index }, id: \.id) { setLog in
                                            if let eSet = setLog.set {
                                                Button {
                                                    let exerciseLogIndex = exerciseLog.index
                                                    
                                                    if let setLogIndex = exerciseLog.setLogs.firstIndex(where: { $0.id == setLog.id }),
                                                       let eSet = exerciseLogs[exerciseLogIndex].setLogs[setLogIndex].set,
                                                       let type = exercises[exerciseLogIndex].exercise?.type {
                                                        
                                                        if type == .weight {
                                                            Popup.show(content: {
                                                                EditWeightSetPopup(set: eSet, log: $exerciseLogs[exerciseLogIndex].setLogs[setLogIndex], restTime: exercise.restTime, timer: restTimer)
                                                            })
                                                        } else if type == .distance {
                                                            Popup.show(content: {
                                                                EditDistanceSetPopup(set: eSet, log: $exerciseLogs[exerciseLogIndex].setLogs[setLogIndex], restTime: exercise.restTime, timer: restTimer)
                                                            })
                                                        }
                                                    }
                                                } label: {
                                                    HStack {
                                                        SetView(set: eSet, setLog: setLog)
                                                        
                                                        Spacer()
                                                        
                                                        if setLog.skipped {
                                                            Image(systemName: "arrowshape.turn.up.right.fill")
                                                                .padding(.horizontal, 8)
                                                                .font(Font.system(size: 16))
                                                        }
                                                    }
                                                }
                                                .foregroundStyle(exerciseLog.setLogs.filter { $0.completed || $0.skipped }.count < setLog.index ? ColorManager.secondary : ColorManager.text)
                                                .disabled(exerciseLog.setLogs.filter { $0.completed || $0.skipped }.count < setLog.index)
                                                
                                                if setLog.index < maxIndex {
                                                    Divider()
                                                        .background(ColorManager.text)
                                                }
                                            }
                                        }
                                        
                                        if exerciseLog.setLogs.allSatisfy({ $0.completed || $0.skipped }) && !log.completed {
                                            Button {
                                                let nextIndex = exercise.sets.isEmpty ? 0 : (exercise.sets.map { $0.index }.max() ?? -1) + 1
                                                
                                                let newSet = exerciseLog.setLogs.sorted { $0.index < $1.index }.compactMap { $0.set }.last?.copy() ?? ExerciseSet(index: 0, type: exercise.exercise?.type ?? .weight)
                                                newSet.index = nextIndex
                                                
                                                exerciseLog.setLogs.append(SetLog(from: newSet))
                                            } label: {
                                                HStack(alignment: .center) {
                                                    Image(systemName: "plus")
                                                        .font(Font.system(size: 12, weight: .bold))
                                                    
                                                    Text("Add Set")
                                                        .bodyText(size: 16, weight: .bold)
                                                }
                                            }
                                            .textColor()
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                                .scrollIndicators(.hidden)
                                .scrollClipDisabled()
                                .scrollContentBackground(.hidden)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rest Time: \(restTime.toString())")
                        
                        Text("Total Time: \(timeIntervalToString(totalTime))")
                    }
                    .statsText(size: 16)
                    .secondaryColor()
                }
                .padding()
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear() {
                let _ = try? restTimer.publish(every: 1, currentTime: $restTime)
                
                totalTime = log.getLength()
                totalTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    totalTime = log.getLength()
                }
            }
            .onDisappear() {
                totalTimer?.invalidate()
                totalTimer = nil
            }
            .onChange(of: allLogsDone) {
                if allLogsDone && !log.completed {
                    Task {
                        try? await Task.sleep(for: .seconds(0.7))
                        
                        Popup.show(content: {
                            ConfirmationPopup(selection: $finishWorkoutSelection, promptText: "Finish \(log.workout?.name ?? "Workout")?", cancelText: "Continue", confirmText: "Finish")
                        })
                    }
                }
            }
            .onChange(of: finishWorkoutSelection) {
                if finishWorkoutSelection {
                    log.finishWorkout()
                    
                    try? context.save()
                    
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
