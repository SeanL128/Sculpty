//
//  PerformSet.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI
import ActivityKit

struct PerformSet: View {
    let workoutLog: WorkoutLog
    let exerciseLog: ExerciseLog
    let setLog: SetLog
    
    @ObservedObject private var restTimer: RestTimer
    
    @StateObject private var activityManager = WorkoutActivityManager.shared
    
    @State private var exercises: [WorkoutExercise]
    @State private var exerciseLogs: [ExerciseLog]
    
    private var isValid: Bool {
        let exerciseLogIndex = exerciseLog.index
        
        if exercises[exerciseLogIndex].exercise?.type != nil,
           let setLogIndex = exerciseLog.setLogs.firstIndex(where: { $0.id == setLog.id }),
           exerciseLogs[exerciseLogIndex].setLogs[setLogIndex].set != nil {
            return true
        }
        
        return false
    }
    
    private var showTextColor: Bool {
        let exerciseLogIndex = exerciseLog.index
        
        guard exercises[exerciseLogIndex].exercise?.type != nil,
              let setLogIndex = exerciseLog.setLogs.firstIndex(where: { $0.id == setLog.id }),
              exerciseLogs[exerciseLogIndex].setLogs[setLogIndex].set != nil else {
            return false
        }
        
        if setLog.completed || setLog.skipped {
            return true
        }
        
        let currentSetIndex = setLog.index
        let allSetsInExercise = exerciseLog.setLogs.sorted { $0.index < $1.index }
        
        for set in allSetsInExercise {
            if set.index < currentSetIndex {
                if !set.completed && !set.skipped {
                    return false
                }
            } else if set.index == currentSetIndex {
                return true
            }
        }
        
        return false
    }
    
    init(workoutLog: WorkoutLog, exerciseLog: ExerciseLog, setLog: SetLog, restTimer: RestTimer) {
        self.workoutLog = workoutLog
        self.exerciseLog = exerciseLog
        self.setLog = setLog
        
        self._restTimer = ObservedObject(wrappedValue: restTimer)
        
        exercises = workoutLog.exerciseLogs.sorted { $0.index < $1.index }.compactMap { $0.exercise }
        exerciseLogs = workoutLog.exerciseLogs.sorted { $0.index < $1.index }
    }
    
    var body: some View {
        if let exercise = exerciseLog.exercise,
           let eSet = setLog.set {
            Button {
                let exerciseLogIndex = exerciseLog.index
                
                if let type = exercises[exerciseLogIndex].exercise?.type,
                   let setLogIndex = exerciseLog.setLogs.firstIndex(where: { $0.id == setLog.id }), // swiftlint:disable:this line_length
                   let eSet = exerciseLogs[exerciseLogIndex].setLogs[setLogIndex].set { // swiftlint:disable:this line_length
                    if type == .weight {
                        Popup.show(content: {
                            EditWeightSetPopup(
                                set: eSet,
                                log: $exerciseLogs[exerciseLogIndex].setLogs[setLogIndex], // swiftlint:disable:this line_length
                                restTime: exercise.restTime,
                                timer: restTimer
                            )
                        }, onDismiss: {
                            activityManager.updateActiveWorkout(workoutLog)
                        })
                    } else if type == .distance {
                        Popup.show(content: {
                            EditDistanceSetPopup(
                                set: eSet,
                                log: $exerciseLogs[exerciseLogIndex].setLogs[setLogIndex], // swiftlint:disable:this line_length
                                restTime: exercise.restTime,
                                timer: restTimer
                            )
                        }, onDismiss: {
                            activityManager.updateActiveWorkout(workoutLog)
                        })
                    }
                }
            } label: {
                HStack(alignment: .center) {
                    SetView(set: eSet, setLog: setLog)
                    
                    Spacer()
                    
                    if setLog.skipped {
                        Image(systemName: "arrowshape.turn.up.right.fill")
                            .padding(.horizontal, 8)
                            .font(Font.system(size: 16))
                    }
                }
                .contentShape(Rectangle())
            }
            .foregroundStyle(showTextColor ? ColorManager.text : ColorManager.secondary)
            .disabled(!isValid)
            .animatedButton(feedback: .selection, isValid: isValid)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isValid)
            
            if setLog.index < (exerciseLog.setLogs.map({ $0.index }).max() ?? 0) {
                Divider()
                    .background(ColorManager.border)
                    .padding(.horizontal, .spacingXS)
            }
        }
    }
}
