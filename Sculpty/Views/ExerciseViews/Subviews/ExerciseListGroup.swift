//
//  ExerciseListGroup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct ExerciseListGroup: View {
    let muscleGroup: MuscleGroup
    let exercises: [Exercise]
    var selectedExercise: Binding<Exercise?>?
    let exerciseOptions: [Exercise]?
    
    init(
        muscleGroup: MuscleGroup,
        exercises: [Exercise],
        selectedExercise: Binding<Exercise?>? = nil,
        exerciseOptions: [Exercise]? = nil
    ) {
        self.muscleGroup = muscleGroup
        self.exercises = exercises
        self.selectedExercise = selectedExercise
        self.exerciseOptions = exerciseOptions
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingS) {
            Text(muscleGroup.rawValue.uppercased())
                .subheadingText()
                .textColor()
            
            VStack(alignment: .leading, spacing: .listSpacing) {
                ForEach(exercises, id: \.id) { exercise in
                    ExerciseListRow(
                        exercise: exercise,
                        selectedExercise: selectedExercise,
                        exerciseOptions: exerciseOptions
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    ))
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: exercises)
            }
        }
    }
}
