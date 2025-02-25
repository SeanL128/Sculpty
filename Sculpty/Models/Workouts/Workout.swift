//
//  Workout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@Model
class Workout: Identifiable, Codable, FileDocument, Transferable {
    static var readableContentTypes: [UTType] = [.json]
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
    
    @Attribute(.unique) var id = UUID()
    
    var index: Int
    var name: String
    @Relationship(deleteRule: .deny, inverse: \WorkoutExercise.workout) var exercises: [WorkoutExercise]
    var notes: String
    
    init(index: Int = -1, name: String = "Workout", exercises: [WorkoutExercise] = [], notes: String = "Notes") {
        self.index = index
        self.name = name
        self.exercises = exercises
        self.notes = notes
    }
    
    enum CodingKeys: String, CodingKey {
        case id, index, name, exercises, notes
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
        name = try container.decode(String.self, forKey: .name)
        exercises = try container.decode([WorkoutExercise].self, forKey: .exercises)
        notes = try container.decode(String.self, forKey: .notes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
        try container.encode(name, forKey: .name)
        try container.encode(exercises, forKey: .exercises)
        try container.encode(notes, forKey: .notes)
    }
    
    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let decoder = JSONDecoder()
        let decodedWorkout = try decoder.decode(Workout.self, from: data)
        
        self.id = decodedWorkout.id
        self.index = decodedWorkout.index
        self.name = decodedWorkout.name
        self.exercises = decodedWorkout.exercises
        self.notes = decodedWorkout.notes
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return FileWrapper(regularFileWithContents: data)
    }
}
