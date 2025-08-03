//
//  WorkoutListRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI
import SwiftData

struct WorkoutListRow: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let workout: Workout
    let workouts: [Workout]
    @Binding var workoutToStart: WorkoutLog?
    
    let editing: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: .spacingM) {
            if editing {
                ReorderControls(
                    moveUp: {
                        if let above = workouts.last(where: { $0.index < workout.index }) {
                            let index = workout.index
                            workout.index = above.index
                            above.index = index
                        }
                    },
                    moveDown: {
                        if let below = workouts.first(where: { $0.index > workout.index }) {
                            let index = workout.index
                            workout.index = below.index
                            below.index = index
                        }
                    },
                    canMoveUp: workouts.last(where: { $0.index < workout.index }) != nil,
                    canMoveDown: workouts.first(where: { $0.index > workout.index }) != nil
                )
            }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: .spacingL) {
                    Button {
                        Popup.show(content: {
                            WorkoutPreviewPopup(workout: workout)
                        })
                    } label: {
                        Text(workout.name)
                            .bodyText()
                    }
                    .animatedButton(scale: 1, feedback: .selection)
                    
                    Spacer()
                    
                    NavigationLink {
                        UpsertWorkout(workout: workout)
                    } label: {
                        Image(systemName: "pencil")
                            .bodyText(weight: .regular)
                    }
                    .textColor()
                    .animatedButton()
                    
                    Button {
                        let log = WorkoutLog(workout: workout)
                        
                        context.insert(log)
                        
                        workoutToStart = log
                        
                        dismiss()
                    } label: {
                        Image(systemName: "play.fill")
                            .bodyText(weight: .regular)
                    }
                    .foregroundStyle(workout.exercises.isEmpty ? ColorManager.secondary : ColorManager.text)
                    .disabled(workout.exercises.isEmpty)
                    .animatedButton(feedback: .impact(weight: .light), isValid: !workout.exercises.isEmpty)
                    .animation(.easeInOut(duration: 0.2), value: workout.exercises.isEmpty)
                }
                
                Text("Last started \(workout.lastStarted != nil ? formatDateWithTime(workout.lastStarted ?? Date()) : "N/A")") // swiftlint:disable:this line_length
                    .captionText()
                    .secondaryColor()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                    .animation(.easeInOut(duration: 0.3), value: workout.lastStarted)
            }
        }
    }
}
