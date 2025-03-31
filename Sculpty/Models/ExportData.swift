//
//  ExportData.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/20/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ExportData: Codable, FileDocument {
    static var readableContentTypes: [UTType] = [.json]
    
    let workouts: [Workout]
    let exercises: [Exercise]
    let workoutLogs: [WorkoutLog]
    let caloriesLogs: [CaloriesLogDTO]
    
    init(workouts: [Workout], exercises: [Exercise], workoutLogs: [WorkoutLog], caloriesLogs: [CaloriesLogDTO]) {
        self.workouts = workouts
        self.exercises = exercises
        self.workoutLogs = workoutLogs
        self.caloriesLogs = caloriesLogs
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self = try JSONDecoder().decode(ExportData.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        return FileWrapper(regularFileWithContents: data)
    }
}
