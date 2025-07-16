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
            HStack(alignment: .center) {
                Text(workout.name)
                    .bodyText(size: 18, weight: .bold)
                    .truncationMode(.tail)
                
                Spacer()
                
                HStack {
                    ProgressView(value: log.getProgress())
                        .frame(height: 6)
                        .frame(width: 100)
                        .progressViewStyle(.linear)
                        .accentColor(ColorManager.text)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .animation(.easeInOut(duration: 0.3), value: log.getProgress())
                    
                    Text("\((round(log.getProgress() * 100)).formatted())%")
                        .statsText(size: 16)
                        .frame(width: 40)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: log.getProgress())
                }
                
                Image(systemName: "chevron.right")
                    .padding(.leading, -2)
                    .font(Font.system(size: 12))
            }
        }
        .textColor()
        .padding(.trailing, 6)
        .animatedButton(scale: 0.98)
    }
}
