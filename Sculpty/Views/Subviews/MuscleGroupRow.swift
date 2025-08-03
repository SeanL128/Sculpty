//
//  MuscleGroupRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct MuscleGroupRow: View {
    let group: MuscleGroup
    
    var body: some View {
        HStack(alignment: .center, spacing: .spacingS) {
            Circle()
                .fill(MuscleGroup.colorMap[group] ?? Color.gray)
                .frame(width: 8, height: 8)
            
            Text(group.rawValue)
                .bodyText()
                .textColor()
        }
    }
}
