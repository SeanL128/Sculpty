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
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Text(workout.name.uppercased())
                    .headingText(size: 16)
                    .multilineTextAlignment(.leading)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        open.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(Font.system(size: 10, weight: .bold))
                        .rotationEffect(.degrees(open ? -180 : 0))
                        .animation(.easeInOut(duration: 0.5), value: open)
                }
                .animatedButton()
            }
            .textColor()
            .padding(.bottom, -8)
            
            if open {
                ForEach(workout.workoutLogs.sorted { $0.start > $1.start }, id: \.id) { log in
                    WorkoutLogRow(log: log)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .bottom))
                        ))
                }
                .animation(.easeInOut(duration: 0.3), value: open)
                .animation(.easeInOut(duration: 0.3), value: workout.workoutLogs)
            }
        }
    }
}
