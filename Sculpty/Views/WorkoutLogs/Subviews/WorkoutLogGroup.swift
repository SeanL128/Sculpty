//
//  WorkoutLogGroup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct WorkoutLogGroup: View {
    let workout: Workout
    
    @State private var open: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingXS) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    open.toggle()
                }
            } label: {
                HStack(alignment: .center, spacing: .spacingS) {
                    Text(workout.name)
                        .subheadingText()
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "chevron.down")
                        .subheadingImage()
                        .rotationEffect(.degrees(open ? -180 : 0))
                }
            }
            .animatedButton(feedback: .selection)
            .textColor()
            
            if open {
                VStack(alignment: .leading, spacing: .listSpacing) {
                    ForEach(workout.workoutLogs.sorted { $0.start > $1.start }, id: \.id) { log in
                        WorkoutLogRow(log: log)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity.combined(with: .move(edge: .bottom))
                            ))
                    }
                    .animation(.easeInOut(duration: 0.3), value: workout.workoutLogs)
                }
            }
        }
        .padding(.bottom, open ? 0 : -.listSpacing)
    }
}
