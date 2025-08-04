//
//  HomeWorkoutRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct HomeWorkoutRow: View {
    let log: WorkoutLog
    let workout: Workout
    
    var body: some View {
        NavigationLink {
            PerformWorkout(log: log)
        } label: {
            HStack(alignment: .center, spacing: .spacingXS) {
                Text(workout.name)
                    .subheadingText()
                    .truncationMode(.tail)
                
                Spacer()
                
                HStack(alignment: .center, spacing: .spacingS) {
                    ProgressView(value: log.getProgress())
                        .frame(height: 6)
                        .frame(width: 100)
                        .progressViewStyle(.linear)
                        .accentColor(ColorManager.text)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .animation(.easeInOut(duration: 0.3), value: log.getProgress())
                    
                    Text("\((round(log.getProgress() * 100)).formatted())%")
                        .bodyText()
                        .frame(width: 50)
                        .monospacedDigit()
                }
                
                Image(systemName: "chevron.right")
                    .bodyImage()
            }
            .contentShape(Rectangle())
        }
        .textColor()
        .animatedButton(feedback: .selection)
    }
}
