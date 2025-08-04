//
//  EditSetRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct EditSetRow: View {
    let set: ExerciseSet
    let sortedSets: [ExerciseSet]
    
    let type: ExerciseType?
    
    @Binding var workoutExercise: WorkoutExercise
    
    var body: some View {
        if let index = workoutExercise.sets.firstIndex(of: set) {
            HStack(alignment: .center, spacing: .spacingM) {
                ReorderControls(
                    moveUp: {
                        if let above = sortedSets.last(where: { $0.index < set.index }) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                let index = set.index
                                set.index = above.index
                                above.index = index
                            }
                        }
                    },
                    moveDown: {
                        if let below = sortedSets.first(where: { $0.index > set.index }) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                let index = set.index
                                set.index = below.index
                                below.index = index
                            }
                        }
                    },
                    canMoveUp: sortedSets.last(where: { $0.index < set.index }) != nil,
                    canMoveDown: sortedSets.first(where: { $0.index > set.index }) != nil
                )
                
                Button {
                    let type = type ?? .weight
                    
                    switch type {
                    case .weight:
                        Popup.show(content: {
                            EditWeightSetPopup(set: set)
                        })
                    case .distance:
                        Popup.show(content: {
                            EditDistanceSetPopup(set: set)
                        })
                    }
                } label: {
                    SetView(set: set)
                }
                .textColor()
                .animatedButton(feedback: .selection)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        var updatedSets = workoutExercise.sets
                        updatedSets.remove(at: index)
                        workoutExercise.sets = updatedSets
                    }
                } label: {
                    Image(systemName: "xmark")
                        .bodyText(weight: .regular)
                }
                .textColor()
                .animatedButton(feedback: .impact(weight: .medium))
            }
        } else {
            HStack(alignment: .center, spacing: .spacingXS) {
                Image(systemName: "exclamationmark.triangle")
                    .bodyImage()
                
                Text("Error")
                    .bodyText()
            }
            .secondaryColor()
        }
    }
}
