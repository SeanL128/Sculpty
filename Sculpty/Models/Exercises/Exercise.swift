//
//  Exercise.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import Foundation
import SwiftData

@Model
class Exercise: Identifiable, Codable {
    @Attribute(.unique) var id = UUID()
    
    var name: String
    var notes: String
    var muscleGroup: MuscleGroup?
    var type: ExerciseType
    var hidden: Bool = false
    
    init(name: String = "", notes: String = "", muscleGroup: MuscleGroup = MuscleGroup.other, type: ExerciseType = .weight) {
        self.name = name
        self.notes = notes
        self.muscleGroup = muscleGroup
        self.type = type
    }
    
    func hide() {
        hidden = true
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, notes, muscleGroup, type, hidden
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        notes = try container.decode(String.self, forKey: .notes)
        muscleGroup = try container.decodeIfPresent(MuscleGroup.self, forKey: .muscleGroup)
        type = try container.decode(ExerciseType.self, forKey: .type)
        hidden = try container.decode(Bool.self, forKey: .hidden)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(notes, forKey: .notes)
        try container.encode(muscleGroup, forKey: .muscleGroup)
        try container.encode(type, forKey: .type)
        try container.encode(hidden, forKey: .hidden)
    }
}
