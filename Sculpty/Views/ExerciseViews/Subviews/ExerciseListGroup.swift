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
        VStack(alignment: .leading, spacing: 9) {
            Text(muscleGroup.rawValue.uppercased())
                .headingText(size: 14)
                .textColor()
                .padding(.bottom, -2)
            
            ForEach(exercises, id: \.id) { exercise in
                ExerciseListRow(
                    exercise: exercise,
                    selectedExercise: selectedExercise,
                    exerciseOptions: exerciseOptions
                )
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: exercises.count)
    }
}
