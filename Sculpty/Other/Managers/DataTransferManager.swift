//
//  DataTransferManager.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/17/25.
//

import Foundation
import SwiftData

class DataTransferManager {
    static let shared = DataTransferManager()
    
    private init() { }
    
    @MainActor
    func importAllData(
        from data: Data,
        into context: ModelContext,
        preserveDefaultExercises: Bool = true,
        defaultExerciseIDs: Set<UUID> = [],
        importSettings: Bool = true
    ) throws {
        guard let appData = AppDataDTO.import(from: data) else {
            throw ImportError.invalidData
        }
        
        try clearAllData(
            in: context,
            preserveDefaultExercises: preserveDefaultExercises,
            defaultExerciseIDs: defaultExerciseIDs
        )
        
        var defaultExercises: [Exercise] = []
        if preserveDefaultExercises && !defaultExerciseIDs.isEmpty {
            let descriptor = FetchDescriptor<Exercise>()
            defaultExercises = try context.fetch(descriptor)
        }
        
        let defaultExerciseIDSet = Set(defaultExercises.map { $0.id })
        let filteredExerciseModels = appData.exercises
            .filter { !defaultExerciseIDSet.contains($0.id) }
            .map { $0.toModel() }
        
        for model in filteredExerciseModels {
            context.insert(model)
        }
        
        var exerciseMap = Dictionary(uniqueKeysWithValues: filteredExerciseModels.map { ($0.id, $0) })
        for exercise in defaultExercises {
            exerciseMap[exercise.id] = exercise
        }
        
        let workoutModels = appData.workouts.map { $0.toModel(exerciseMap: exerciseMap) }
        for workout in workoutModels {
            for workoutExercise in workout.exercises {
                workoutExercise.workout = workout
                
                for set in workoutExercise.sets {
                    set.workoutExercise = workoutExercise
                    
                    if set.unit.isEmpty {
                        set.unit = set.exerciseType == .weight ? UnitsManager.weight : UnitsManager.longLength
                    }
                }
            }
            
            context.insert(workout)
        }
        
        var allSetModels: [ExerciseSet] = []
        for workout in workoutModels {
            for workoutExercise in workout.exercises {
                allSetModels.append(contentsOf: workoutExercise.sets)
            }
        }
        
        let setMap = Dictionary(uniqueKeysWithValues: allSetModels.map { ($0.id, $0) })
        
        let workoutMap = Dictionary(uniqueKeysWithValues: workoutModels.map { ($0.id, $0) })
        
        for workoutLogDTO in appData.workoutLogs {
            if let workout = workoutMap[workoutLogDTO.workout.id] {
                let workoutLog = WorkoutLog(
                    workout: workout,
                    started: workoutLogDTO.started,
                    completed: workoutLogDTO.completed,
                    start: workoutLogDTO.start,
                    end: workoutLogDTO.end
                )
                workoutLog.id = workoutLogDTO.id
                
                workoutLog.exerciseLogs = []
                
                for exerciseLogDTO in workoutLogDTO.exerciseLogs {
                    var workoutExercise: WorkoutExercise?
                    
                    if workoutExercise == nil, let exerciseId = exerciseLogDTO.exercise.exerciseId {
                        workoutExercise = workout.exercises.first(where: { $0.exercise?.id == exerciseId })
                    }
                    
                    if let workoutExercise = workoutExercise {
                        let exerciseLog = ExerciseLog(index: exerciseLogDTO.index, exercise: workoutExercise)
                        exerciseLog.id = exerciseLogDTO.id
                        exerciseLog.completed = exerciseLogDTO.completed
                        exerciseLog.start = exerciseLogDTO.start
                        exerciseLog.end = exerciseLogDTO.end
                        exerciseLog.workoutLog = workoutLog
                        
                        exerciseLog.setLogs = []
                        
                        for setLogDTO in exerciseLogDTO.setLogs {
                            let setLog = setLogDTO.toModel(setMap: setMap)
                            
                            if setLog.unit.isEmpty {
                                if let set = setLog.set {
                                    setLog.unit = set.unit
                                } else {
                                    setLog.unit = UnitsManager.weight
                                }
                            }
                            
                            exerciseLog.setLogs.append(setLog)
                            setLog.exerciseLog = exerciseLog
                        }
                        
                        workoutLog.exerciseLogs.append(exerciseLog)
                    }
                }
                
                context.insert(workoutLog)
            }
        }
        
        for measurementDTO in appData.measurements {
            context.insert(measurementDTO.toModel())
        }
        
        for customFoodDTO in appData.customFoods {
            context.insert(customFoodDTO.toModel())
        }
        
        for caloriesLogDTO in appData.caloriesLogs {
            let caloriesLog = caloriesLogDTO.toModel()
            
            for entry in caloriesLog.entries {
                entry.caloriesLog = caloriesLog
            }
            
            context.insert(caloriesLog)
        }
        
        if importSettings, let userSettings = appData.userSettings {
            userSettings.applyTo(settings: CloudSettings.shared)
        }
        
        try context.save()
        
        if context.hasChanges {
            try context.save()
        }
    }
    
    @MainActor
    func clearAllData(
        in context: ModelContext,
        preserveDefaultExercises: Bool = true,
        defaultExerciseIDs: Set<UUID> = []
    ) throws {
        do {
            let workoutExercises = try context.fetch(FetchDescriptor<WorkoutExercise>())
            for workoutExercise in workoutExercises {
                workoutExercise.exercise = nil
            }
            
            try deleteAllEntities(of: SetLog.self, in: context)
            try deleteAllEntities(of: ExerciseLog.self, in: context)
            try deleteAllEntities(of: WorkoutLog.self, in: context)
            try deleteAllEntities(of: ExerciseSet.self, in: context)
            try deleteAllEntities(of: WorkoutExercise.self, in: context)
            try deleteAllEntities(of: Workout.self, in: context)
            
            if preserveDefaultExercises && !defaultExerciseIDs.isEmpty {
                let descriptor = FetchDescriptor<Exercise>(predicate: #Predicate<Exercise> { exercise in
                    !defaultExerciseIDs.contains(exercise.id)
                })
                
                let nonDefaultExercises = try context.fetch(descriptor)
                
                for exercise in nonDefaultExercises {
                    context.delete(exercise)
                }
            } else {
                try deleteAllEntities(of: Exercise.self, in: context)
            }
            
            try deleteAllEntities(of: FoodEntry.self, in: context)
            try deleteAllEntities(of: CaloriesLog.self, in: context)
            try deleteAllEntities(of: CustomFood.self, in: context)
            try deleteAllEntities(of: Measurement.self, in: context)
            
            try context.save()
        } catch {
            debugLog("Error during clearAllData: \(error.localizedDescription)")
            throw error
        }
    }
    
    @MainActor
    private func deleteAllEntities<T: PersistentModel>(of type: T.Type, in context: ModelContext) throws {
        let entities = try context.fetch(FetchDescriptor<T>())
        
        for entity in entities {
            context.delete(entity)
        }
    }
}
