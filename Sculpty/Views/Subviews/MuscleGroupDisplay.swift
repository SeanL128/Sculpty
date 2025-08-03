//
//  MuscleGroupDisplay.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct MuscleGroupDisplay: View {
    let groups: [MuscleGroup]
    
    var alignment: HorizontalAlignment = .leading
    
    var body: some View {
        VStack(alignment: alignment, spacing: .spacingXS) {
            Text("Muscle Groups Worked:")
                .bodyText()
                .textColor()
            
            VStack(alignment: alignment, spacing: .spacingS) {
                ForEach(Array(MuscleGroup.displayOrder.enumerated()), id: \.element.id) { index, group in
                    if group != .overall && groups.contains(group) {
                        MuscleGroupRow(group: group)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .leading)),
                                removal: .opacity.combined(with: .move(edge: .trailing))
                            ))
                            .animation(.easeInOut(duration: 0.2).delay(Double(index) * 0.05), value: groups)
                    }
                }
            }
        }
    }
}
