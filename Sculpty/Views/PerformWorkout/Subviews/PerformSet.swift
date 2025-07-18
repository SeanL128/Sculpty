//
//  PerformSet.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct PerformSet: View {
    let workoutLog: WorkoutLog
    let exerciseLog: ExerciseLog
    let setLog: SetLog
    
    @ObservedObject private var restTimer: RestTimer
    
    @State private var exercises: [WorkoutExercise]
    @State private var exerciseLogs: [ExerciseLog]
    
    private var isValid: Bool {
        exerciseLog.setLogs.filter { $0.completed || $0.skipped }.count >= setLog.index
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
                        })
                    } else if type == .distance {
                        Popup.show(content: {
                            EditDistanceSetPopup(
                                set: eSet,
                                log: $exerciseLogs[exerciseLogIndex].setLogs[setLogIndex], // swiftlint:disable:this line_length
                                restTime: exercise.restTime,
                                timer: restTimer
                            )
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
                .contentShape(Rectangle())
            }
            .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
            .disabled(!isValid)
            .animatedButton(scale: 0.98, isValid: isValid)
            .animation(.easeInOut(duration: 0.2), value: isValid)
            .animation(.easeInOut(duration: 0.3), value: setLog.skipped)
            
            if setLog.index < (exerciseLog.setLogs.map({ $0.index }).max() ?? 0) {
                Divider()
                    .background(ColorManager.text)
                    .padding(.horizontal)
            }
        }
    }
}
