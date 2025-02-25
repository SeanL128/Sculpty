//
//  WorkoutLogViewModel.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/8/25.
//

import Foundation
import SwiftData

class WorkoutLogViewModel: ObservableObject {
    @Published var workoutLog: WorkoutLog
    
    init(workoutLog: WorkoutLog) {
        self.workoutLog = workoutLog
    }
    
    var exerciseLogs: [ExerciseLog] {
        workoutLog.exerciseLogs.sorted { $0.exercise.index < $1.exercise.index }
    }
    
    func completedSetLogs(for exerciseLog: ExerciseLog) -> [SetLog] {
        exerciseLog.setLogs.filter { $0.completed }.sorted { $0.start < $1.start }
    }
    
    func deleteExerciseLog(_ log: ExerciseLog, context: ModelContext) {
        workoutLog.exerciseLogs.removeAll { $0.id == log.id }
        try? context.save()
    }
}
