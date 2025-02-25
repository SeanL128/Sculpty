//
//  ExerciseViewModel.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/16/25.
//

import Foundation
import SwiftData

class ExerciseViewModel: ObservableObject {
    @Published var name: String
    @Published var notes: String
    @Published var muscleGroup: MuscleGroup
    
    private var exercise: Exercise
    
    init(exercise: Exercise = Exercise()) {
        self.exercise = exercise
        self.name = exercise.name
        self.notes = exercise.notes
        self.muscleGroup = exercise.muscleGroup ?? .other
    }
    
    func save(context: ModelContext, insert: Bool) {
        exercise.name = name
        exercise.notes = notes
        exercise.muscleGroup = muscleGroup
        
        
        if insert {
            context.insert(exercise)
        }
        try? context.save()
    }
}
