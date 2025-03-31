//
//  BaseSet.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/24/25.
//

import Foundation
import SwiftData

class BaseSet: Identifiable, Codable {
    @Attribute(.unique) var id = UUID()
    var workoutExercise: WorkoutExercise?
    var index: Int

    init(index: Int = 0) {
        self.index = index
    }

    enum CodingKeys: String, CodingKey {
        case id, index
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        index = try container.decode(Int.self, forKey: .index)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(index, forKey: .index)
    }
}
