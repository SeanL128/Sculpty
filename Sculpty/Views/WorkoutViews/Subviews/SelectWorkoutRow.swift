//
//  SelectWorkoutRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct SelectWorkoutRow: View {
    let workout: Workout
    
    @Binding var selectedWorkout: Workout?

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedWorkout = workout
            }
        } label: {
            HStack(alignment: .center, spacing: .spacingXS) {
                Text(workout.name)
                    .bodyText(weight: selectedWorkout == workout ? .bold : .regular)
                    .multilineTextAlignment(.leading)
                
                if !workout.workoutLogs.isEmpty {
                    Image(systemName: "chevron.right")
                        .bodyImage(weight: selectedWorkout == workout ? .bold : .medium)
                }
                
                Spacer()
                
                if selectedWorkout == workout {
                    Image(systemName: "checkmark")
                        .bodyText()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.8)),
                            removal: .opacity.combined(with: .scale(scale: 0.8))
                        ))
                }
            }
        }
        .foregroundStyle(!workout.workoutLogs.isEmpty ? ColorManager.text : ColorManager.secondary)
        .disabled(workout.workoutLogs.isEmpty)
        .animatedButton(feedback: .selection, isValid: !workout.workoutLogs.isEmpty)
    }
}
