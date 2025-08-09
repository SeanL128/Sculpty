//
//  PerformExercise.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct PerformExercise: View {
    @EnvironmentObject private var settings: CloudSettings
    
    let workoutLog: WorkoutLog
    let exerciseLog: ExerciseLog
    
    @ObservedObject var restTimer: RestTimer
    
    var body: some View {
        if let exercise = exerciseLog.exercise {
            ScrollView {
                VStack(alignment: .leading, spacing: .spacingM) {
                    VStack(alignment: .leading, spacing: .spacingXS) {
                        Text(exercise.exercise?.name ?? "Exercise \(exercise.index + 1)")
                            .subheadingText()
                            .textColor()
                        
                        if settings.showTempo {
                            Button {
                                Popup.show(content: {
                                    TempoPopup(tempo: exercise.tempo)
                                })
                            } label: {
                                HStack(alignment: .center, spacing: .spacingXS) {
                                    Text("Tempo: \(exercise.tempo)")
                                        .secondaryText()
                                    
                                    Image(systemName: "chevron.right")
                                        .secondaryImage()
                                }
                            }
                            .textColor()
                            .animatedButton(feedback: .selection)
                        }
                        
                        if !exercise.specNotes.isEmpty {
                            Button {
                                Popup.show(content: {
                                    InfoPopup(
                                        title: "\(exercise.exercise?.name ?? "Exercise") Notes",
                                        text: exercise.specNotes
                                    )
                                })
                            } label: {
                                HStack(alignment: .center, spacing: .spacingXS) {
                                    Text("Notes")
                                        .secondaryText()
                                    
                                    Image(systemName: "chevron.right")
                                        .secondaryImage()
                                }
                            }
                            .textColor()
                            .animatedButton(feedback: .selection)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: .spacingXS) {
                        ForEach(exerciseLog.setLogs.sorted { $0.index < $1.index }, id: \.id) { setLog in
                            PerformSet(
                                workoutLog: workoutLog,
                                exerciseLog: exerciseLog,
                                setLog: setLog,
                                restTimer: restTimer
                            )
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .leading)),
                                removal: .opacity.combined(with: .move(edge: .trailing))
                            ))
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: exerciseLog.setLogs.count)
                    }
                    
                    if exerciseLog.setLogs.allSatisfy({ $0.completed || $0.skipped }),
                       !workoutLog.completed {
                        Button {
                            let nextIndex = exercise.sets.isEmpty ? 0 : (exercise.sets.map { $0.index }.max() ?? -1) + 1 // swiftlint:disable:this line_length
                            
                            let newSet = exerciseLog.setLogs
                                .sorted { $0.index < $1.index }
                                .compactMap { $0.set }
                                .last?
                                .copy() ?? ExerciseSet(
                                    index: 0,
                                    type: exercise.exercise?.type ?? .weight
                                )
                            newSet.index = nextIndex
                            
                            exerciseLog.setLogs.append(SetLog(from: newSet))
                        } label: {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Image(systemName: "plus")
                                    .secondaryImage(weight: .bold)
                                
                                Text("Add Set")
                                    .secondaryText()
                            }
                        }
                        .textColor()
                        .animatedButton()
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .scrollContentBackground(.hidden)
        }
    }
}
