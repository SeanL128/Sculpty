//
//  WorkoutExercise.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/17/25.
//

import Foundation
import SwiftData

@Model
class WorkoutExercise: Identifiable {
    var id = UUID()
    var workout: Workout?
    
    var index: Int = 0
    @Relationship(deleteRule: .nullify, inverse: \Exercise._workoutExercises) var exercise: Exercise?
    private var _sets: [ExerciseSet]?
    var sets: [ExerciseSet] {
        get { _sets ?? [] }
        set { _sets = newValue.isEmpty ? nil : newValue }
    }
    var restTime: TimeInterval = 180
    var specNotes: String = ""
    var tempo: String = "0000"
    
    var _exerciseLogs: [ExerciseLog]?
    var exerciseLogs: [ExerciseLog] {
        get { _exerciseLogs ?? [] }
        set { _exerciseLogs = newValue.isEmpty ? nil : newValue }
    }
    
    init(
        index: Int = 0,
        exercise: Exercise? = nil,
        sets: [ExerciseSet] = [],
        restTime: TimeInterval = 180,
        specNotes: String = "",
        tempo: String = "0000"
    ) {
        self.index = index
        self.exercise = exercise
        self.sets = sets
        self.restTime = restTime
        self.specNotes = specNotes
        self.tempo = tempo
    }
    
    func addSet() {
        sets = sets.sorted { $0.index < $1.index }
        
        let index = (sets.map { $0.index }.max() ?? -1) + 1
        let set = ExerciseSet(index: index, type: exercise?.type ?? .weight)
        sets.append(set)
    }
    
    func deleteSet(at index: Int) {
        guard sets.indices.contains(index) else { return }
        
        let i = sets[index].index
        sets.remove(at: index)
        
        for set in sets where set.index > i {
            set.index -= 1
        }
    }
    
    func copy() -> WorkoutExercise {
        return WorkoutExercise(from: self)
    }
    
    private init (from e: WorkoutExercise) {
        index = e.index
        exercise = e.exercise
        sets = []
        restTime = e.restTime
        specNotes = e.specNotes
        tempo = e.tempo
        
        for s in e.sets.sorted(by: { $0.index < $1.index }) {
            sets.append(s.copy())
        }
    }
}
