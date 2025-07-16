//
//  SelectWorkoutRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct SelectWorkoutRow: View {
    let workout: Workout
    let forStats: Bool
    
    @Binding var selectedWorkout: Workout?
    
    private var isValid: Bool {
        !forStats || !workout.workoutLogs.isEmpty
    }

    var body: some View {
        Button {
            selectedWorkout = workout
        } label: {
            HStack(alignment: .center) {
                Text(workout.name)
                    .bodyText(size: 16, weight: selectedWorkout == workout ? .bold : .regular)
                    .multilineTextAlignment(.leading)
                    .animation(.easeInOut(duration: 0.2), value: selectedWorkout == workout)
                
                if !workout.workoutLogs.isEmpty {
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 10, weight: selectedWorkout == workout ? .bold : .regular))
                        .animation(.easeInOut(duration: 0.2), value: selectedWorkout == workout)
                }
                
                if selectedWorkout == workout {
                    Spacer()
                    
                    Image(systemName: "checkmark")
                        .padding(.horizontal, 8)
                        .font(Font.system(size: 16))
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.8)),
                            removal: .opacity.combined(with: .scale(scale: 0.8))
                        ))
                }
            }
        }
        .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
        .disabled(!isValid)
        .animatedButton(scale: 0.98, feedback: .selection, isValid: isValid)
        .animation(.easeInOut(duration: 0.3), value: selectedWorkout == workout)
    }
}
