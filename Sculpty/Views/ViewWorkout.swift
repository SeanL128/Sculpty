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
    @Environment(\.modelContext) var context
    
    @State private var log: WorkoutLog
    @State private var exercises: [WorkoutExercise]
    @State private var exerciseLogs: [ExerciseLog]
    
    private let restTimer: MTimer
    @State private var restTime: MTime = .init()
    
    @State private var totalTimer: Timer?
    @State private var totalTime: Double
    
    @AppStorage(UserKeys.disableAutoLock.rawValue) private var disableAutoLock: Bool = false
    
    init(log: WorkoutLog) {
        self.log = log
        
        self.exercises = log.exerciseLogs.sorted { $0.index < $1.index }.map(\.exercise)
        self.exerciseLogs = log.exerciseLogs.sorted { $0.index < $1.index }
        
        self.restTimer = MTimer(MTimerID(rawValue: "Rest Timer \(log.id)"))
        
        self.totalTime = log.getLength()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(log.workout.name)
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                    }
                    .padding()
                    
                    TabView {
                        ForEach(log.exerciseLogs, id: \.self) { exerciseLog in
                            let exercise = exerciseLog.exercise
                            
                            VStack(alignment: .leading, spacing: 12) {
                                let maxIndex = exerciseLog.setLogs.sorted(by: { $0.index < $1.index }).last?.index ?? 0
                                
                                ForEach(exerciseLog.setLogs.sorted { $0.index < $1.index }, id: \.self) { setLog in
                                    if let eSet = setLog.set {
                                        Button {
                                            let exerciseIndex = exercise.index
                                            let exerciseLogIndex = exerciseLog.index
                                            
                                            Task {
                                                if let setIndex = exercises[exerciseIndex].sets.firstIndex(where: { $0.id == eSet.id }),
                                                   let setLogIndex = exerciseLog.setLogs.firstIndex(where: { $0.id == setLog.id }) {
                                                    let type = exercises[exerciseLogIndex].sets[setIndex].exerciseType
                                                    
                                                    if type == .weight {
                                                        await EditWeightSetPopup(set: $exercises[exerciseLogIndex].sets[setIndex], log: $exerciseLogs[exerciseLogIndex].setLogs[setLogIndex], restTime: exercise.restTime, timer: restTimer).present()
                                                    } else if type == .distance {
                                                        await EditDistanceSetPopup(set: $exercises[exerciseLogIndex].sets[setIndex], log: $exerciseLogs[exerciseLogIndex].setLogs[setLogIndex], restTime: exercise.restTime, timer: restTimer).present()
                                                    }
                                                }
                                                
                                                checkAllDone(log: exerciseLog)
                                            }
                                        } label: {
                                            HStack {
                                                SetView(set: eSet, setLog: setLog)
                                                
                                                Spacer()
                                                
                                                if setLog.skipped {
                                                    Image(systemName: "arrowshape.turn.up.right.fill")
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
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("REST TIME: \(restTime.toString())")
                        
                        Text("TOTAL TIME: \(timeIntervalToString(totalTime))")
                    }
                }
                .padding()
            }
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
        }
    }
    
    private func checkAllDone(log: ExerciseLog) {
        var allDone: Bool = true
        
        for log in log.setLogs {
            if !log.completed && !log.skipped {
                allDone = false
                break
            }
        }
        
        if allDone {
            log.finish()
        }
        
        try? context.save()
    }
    
    private func timeIntervalToString(_ time: Double) -> String {
        let interval = Int(time)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / (60*60)) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
