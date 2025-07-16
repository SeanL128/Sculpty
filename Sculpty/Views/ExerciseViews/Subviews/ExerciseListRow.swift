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
    
    @State private var selectionTrigger: Int = 0
    
    init(
        exercise: Exercise,
        selectedExercise: Binding<Exercise?>? = nil,
        exerciseOptions: [Exercise]? = nil
    ) {
        self.exercise = exercise
        self.selectedExercise = selectedExercise
        isSelectable = exerciseOptions?.contains(exercise) == true
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Text(exercise.name)
                .bodyText(size: 16)
                .multilineTextAlignment(.leading)
            
            if isSelectable {
                Image(systemName: "chevron.right")
                    .padding(.leading, -2)
                    .font(
                        Font.system(
                            size: 10,
                            weight: selectedExercise?.wrappedValue == exercise ? .bold : .regular
                        )
                    )
                    .animation(.easeInOut(duration: 0.2), value: selectedExercise?.wrappedValue == exercise)
            }
            
            Spacer()
            
            if selectedExercise == nil {
                NavigationLink {
                    UpsertExercise(exercise: exercise)
                } label: {
                    Image(systemName: "pencil")
                        .padding(.horizontal, 8)
                        .font(Font.system(size: 16))
                }
                .animatedButton()
            } else if selectedExercise?.wrappedValue == exercise {
                Image(systemName: "checkmark")
                    .padding(.horizontal, 8)
                    .font(Font.system(size: 16))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .textColor()
        .padding(.trailing, 1)
        .contentShape(Rectangle())
        .onTapGesture {
            if let selectedExercise = selectedExercise {
                selectionTrigger += 1
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedExercise.wrappedValue = exercise
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectionTrigger)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedExercise?.wrappedValue)
    }
}
