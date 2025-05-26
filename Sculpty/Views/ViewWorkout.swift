//
//  ViewWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/22/25.
//

import SwiftUI
import SwiftData
import MijickPopups
import MijickTimer

struct ViewWorkout: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var log: WorkoutLog
    @State private var exercises: [WorkoutExercise]
    @State private var exerciseLogs: [ExerciseLog]
    
    private let restTimer: MTimer
    @State private var restTime: MTime = .init()
    
    @State private var totalTimer: Timer?
    @State private var totalTime: Double
    
    @State private var finishWorkoutSelection: Bool = false
    
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
    
    @AppStorage(UserKeys.disableAutoLock.rawValue) private var disableAutoLock: Bool = false
    @AppStorage(UserKeys.showTempo.rawValue) private var showTempo: Bool = false
    
    init(log: WorkoutLog) {
        self.log = log
        
        exercises = log.exerciseLogs.sorted { $0.index < $1.index }.map { $0.exercise }
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
                        
                        Text(log.workout.name)
                            .headingText(size: 32)
                            .textColor()
                        
                        Spacer()
                        
                        Button {
                            if log.completed {
                                Task {
                                    await WorkoutSummaryPopup(log: log).present()
                                }
                            } else {
                                Task {
                                    await ConfirmationPopup(selection: $finishWorkoutSelection, promptText: "Finish \(log.workout.name)?", resultText: "This will skip all remaining sets.", cancelText: "Cancel", confirmText: "Finish").present()
                                }
                            }
                        } label: {
                            Image(systemName: log.completed ? "checkmark.circle.fill" : "checkmark.circle")
                                .padding(.horizontal, 3)
                                .font(Font.system(size: 24))
                        }
                        .textColor()
                    }
                    .padding(.bottom)
                    
                    TabView {
                        ForEach(log.exerciseLogs.sorted { $0.index < $1.index }, id: \.self) { exerciseLog in
                            let exercise = exerciseLog.exercise
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    VStack(alignment: .leading) {
                                        Text(exercise.exercise?.name ?? "Exercise \(exercise.index + 1)")
                                            .bodyText(size: 18, weight: .bold)
                                            .textColor()
                                        
                                        if showTempo {
                                            let tempoArr = Array(exercise.tempo)
                                            
                                            Button {
                                                Task {
                                                    await TempoPopup(tempo: exercise.tempo).present()
                                                }
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
                                                Task {
                                                    await InfoPopup(title: "\(exercise.exercise?.name ?? "Exercise") Notes", text: exercise.specNotes).present()
                                                }
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
                                    
                                    let maxIndex = exerciseLog.setLogs.sorted(by: { $0.index < $1.index }).last?.index ?? 0
                                    
                                    ForEach(exerciseLog.setLogs.sorted { $0.index < $1.index }, id: \.self) { setLog in
                                        if let eSet = setLog.set {
                                            Button {
                                                let exerciseIndex = exercise.index
                                                let exerciseLogIndex = exerciseLog.index
                                                
                                                Task {
                                                    if let setIndex = exercises[exerciseIndex].sets.firstIndex(where: { $0.id == eSet.id }),
                                                       let setLogIndex = exerciseLog.setLogs.firstIndex(where: { $0.id == setLog.id }),
                                                       let type = exercises[exerciseLogIndex].exercise?.type {
                                                        if type == .weight {
                                                            await EditWeightSetPopup(set: exercises[exerciseLogIndex].sets[setIndex], log: $exerciseLogs[exerciseLogIndex].setLogs[setLogIndex], restTime: exercise.restTime, timer: restTimer).present()
                                                        } else if type == .distance {
                                                            await EditDistanceSetPopup(set: exercises[exerciseLogIndex].sets[setIndex], log: $exerciseLogs[exerciseLogIndex].setLogs[setLogIndex], restTime: exercise.restTime, timer: restTimer).present()
                                                        }
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
                                            .disabled(exerciseLog.setLogs.filter { $0.completed || $0.skipped }.count < setLog.index)
                                            .foregroundStyle(exerciseLog.setLogs.filter { $0.completed || $0.skipped }.count < setLog.index ? ColorManager.secondary : ColorManager.text)
                                            
                                            if setLog.index < maxIndex {
                                                Divider()
                                                    .background(ColorManager.text)
                                            }
                                        }
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
                
                if disableAutoLock {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
            }
            .onDisappear() {
                UIApplication.shared.isIdleTimerDisabled = false
                
                totalTimer?.invalidate()
                totalTimer = nil
            }
            .onChange(of: allLogsDone) {
                if allLogsDone && !log.completed {
                    Task {
                        try? await Task.sleep(for: .seconds(0.7))
                        
                        await ConfirmationPopup(selection: $finishWorkoutSelection, promptText: "Finish \(log.workout.name)?", cancelText: "Continue", confirmText: "Finish").present()
                    }
                }
            }
            .onChange(of: finishWorkoutSelection) {
                if finishWorkoutSelection {
                    log.finishWorkout()
                    
                    try? context.save()
                    
                    Task {
                        await WorkoutSummaryPopup(log: log).present()
                    }
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
