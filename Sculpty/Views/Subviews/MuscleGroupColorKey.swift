//
//  MuscleGroupColorKey.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/10/25.
//

import SwiftUI

struct MuscleGroupColorKey: View {
    var muscleGroups: [MuscleGroup]
    
    var body: some View {
        HStack {
            ForEach(MuscleGroup.displayOrder, id: \.self) { group in
                if group != .overall && muscleGroups.contains(group) {
                    HStack {
                        Circle()
                            .fill(MuscleGroup.colorMap[group]!)
                            .frame(width: 10, height: 10)
                        
                        Text(group.rawValue.capitalized)
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    MuscleGroupColorKey(muscleGroups: [])
}
