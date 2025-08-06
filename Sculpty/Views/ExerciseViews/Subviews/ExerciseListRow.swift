//
//  ExerciseListRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct ExerciseListRow: View {
    let exercise: Exercise
    var selectedExercise: Binding<Exercise?>?
    let isSelectable: Bool
    let exerciseOptions: [Exercise]?
    
    init(
        exercise: Exercise,
        selectedExercise: Binding<Exercise?>? = nil,
        exerciseOptions: [Exercise]? = nil
    ) {
        self.exercise = exercise
        self.selectedExercise = selectedExercise
        self.exerciseOptions = exerciseOptions
        isSelectable = exerciseOptions?.contains(exercise) == true
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: .spacingXS) {
            Button {
                if let selectedExercise = selectedExercise {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedExercise.wrappedValue = exercise
                    }
                }
            } label: {
                HStack(alignment: .center, spacing: .spacingXS) {
                    Text(exercise.name)
                        .bodyText(weight: selectedExercise?.wrappedValue == exercise ? .bold : .regular)
                        .multilineTextAlignment(.leading)
                    
                    if selectedExercise != nil && isSelectable {
                        Image(systemName: "chevron.right")
                            .bodyImage(weight: selectedExercise?.wrappedValue == exercise ? .bold : .medium)
                    }
                }
            }
            .foregroundStyle(exerciseOptions != nil && !(exerciseOptions?.contains(where: { $0 == exercise }) ?? true) ? ColorManager.secondary : ColorManager.text) // swiftlint:disable:this line_length
            .animatedButton(feedback: .selection, isValid: selectedExercise != nil && isSelectable)
            
            Spacer()
            
            if selectedExercise == nil {
                NavigationLink {
                    UpsertExercise(exercise: exercise)
                } label: {
                    Image(systemName: "pencil")
                        .bodyText(weight: .regular)
                }
                .animatedButton()
            } else if selectedExercise?.wrappedValue == exercise {
                Image(systemName: "checkmark")
                    .bodyText(weight: .regular)
            }
        }
        .textColor()
    }
}
