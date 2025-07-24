//
//  WorkoutPreviewPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/17/25.
//

import SwiftUI

struct WorkoutPreviewPopup: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center) {
                Spacer()
                
                Text(workout.name)
                    .bodyText(size: 18, weight: .bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            ScrollView {
                if !workout.exercises.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(
                            Array(
                                workout.exercises.sorted {
                                    $0.index < $1.index
                                }.enumerated()
                            ),
                            id: \.element.id
                        ) { index, exercise in
                            ExercisePreview(exercise: exercise, index: index)
                        }
                    }
                } else {
                    Text("No Exercises")
                        .bodyText(size: 16)
                        .textColor()
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxHeight: 300)
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            
            HStack(alignment: .center) {
                Spacer()
                
                Button {
                    Popup.dismissLast()
                } label: {
                    Text("OK")
                        .bodyText(size: 18, weight: .bold)
                        .multilineTextAlignment(.leading)
                }
                .textColor()
                .animatedButton()
                
                Spacer()
            }
        }
    }
}
