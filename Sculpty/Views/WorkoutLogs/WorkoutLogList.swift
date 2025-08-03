//
//  WorkoutLogList.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/26/25.
//

import SwiftUI
import SwiftData

struct WorkoutLogList: View {
    @Environment(\.modelContext) private var context
    
    @Query(filter: #Predicate<Workout> { $0.index >= 0 && !$0.hidden }, sort: \.index) private var workouts: [Workout]

    private var validWorkouts: [Workout] {
        workouts.filter { !$0.workoutLogs.isEmpty }
    }
    
    var body: some View {
        ContainerView(title: "Workout Logs", spacing: .spacingL, lazy: true) {
            if !validWorkouts.isEmpty {
                ForEach(validWorkouts, id: \.id) { workout in
                    WorkoutLogGroup(workout: workout)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                }
                .animation(.easeInOut(duration: 0.4), value: validWorkouts.count)
                .animation(.easeInOut(duration: 0.3), value: validWorkouts.map { $0.workoutLogs.count })
            } else {
                EmptyState(
                    image: "dumbbell",
                    text: "No workouts logged",
                    subtext: "Log your first workout"
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: validWorkouts.isEmpty)
    }
}
