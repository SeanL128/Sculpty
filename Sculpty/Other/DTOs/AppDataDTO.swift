//
//  AppDataDTO.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/17/25.
//

import Foundation

struct AppDataDTO: Codable {
    var exercises: [ExerciseDTO]
    var workouts: [WorkoutDTO]
    var workoutLogs: [WorkoutLogDTO]
    var measurements: [MeasurementDTO]
    var caloriesLogs: [CaloriesLogDTO]
    var userSettings: UserSettingsDTO?
    
    func toModels() -> (
        exercises: [Exercise],
        workouts: [Workout],
        workoutLogs: [WorkoutLog],
        measurements: [Measurement],
        caloriesLogs: [CaloriesLog]
    ) {
        let exerciseModels = exercises.map { $0.toModel() }
        let exerciseMap = Dictionary(uniqueKeysWithValues: exerciseModels.map { ($0.id, $0) })
        
        let workoutModels = workouts.map { $0.toModel(exerciseMap: exerciseMap) }
        
        var allSetModels: [ExerciseSet] = []
        for workout in workoutModels {
            for workoutExercise in workout.exercises {
                allSetModels.append(contentsOf: workoutExercise.sets)
            }
        }
        let setMap = Dictionary(uniqueKeysWithValues: allSetModels.map { ($0.id, $0) })
        
        let workoutLogModels = workoutLogs.map { $0.toModel(exerciseMap: exerciseMap, setMap: setMap) }
        let measurementModels = measurements.map { $0.toModel() }
        let caloriesLogModels = caloriesLogs.map { $0.toModel() }
        
        return (
            exercises: exerciseModels,
            workouts: workoutModels,
            workoutLogs: workoutLogModels,
            measurements: measurementModels,
            caloriesLogs: caloriesLogModels
        )
    }
    
    static func export(
        exercises: [Exercise],
        workouts: [Workout],
        workoutLogs: [WorkoutLog],
        measurements: [Measurement],
        caloriesLogs: [CaloriesLog],
        includeSettings: Bool = true
    ) -> Data? {
        let exerciseDTOs = exercises.map { ExerciseDTO(from: $0) }
        let workoutDTOs = workouts.map { WorkoutDTO(from: $0) }
        let workoutLogDTOs = workoutLogs.map { WorkoutLogDTO(from: $0) }
        let measurementDTOs = measurements.map { MeasurementDTO(from: $0) }
        let caloriesLogDTOs = caloriesLogs.map { CaloriesLogDTO(from: $0) }
        
        let userSettingsDTO = includeSettings ? UserSettingsDTO(from: CloudSettings.shared) : nil
        
        let appData = AppDataDTO(
            exercises: exerciseDTOs,
            workouts: workoutDTOs,
            workoutLogs: workoutLogDTOs,
            measurements: measurementDTOs,
            caloriesLogs: caloriesLogDTOs,
            userSettings: userSettingsDTO
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            return try encoder.encode(appData)
        } catch {
            debugLog("Error encoding app data: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func `import`(from data: Data) -> AppDataDTO? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(AppDataDTO.self, from: data)
        } catch {
            debugLog("Error decoding app data: \(error.localizedDescription)")
            return nil
        }
    }
}
