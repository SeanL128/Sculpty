//
//  WorkoutStats.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/23/25.
//

import SwiftUI
import SwiftData
import Charts

struct WorkoutStats: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query private var workoutLogs: [WorkoutLog]
    
    private var show: Bool { !workoutLogs.isEmpty }
    
    @State private var selectedTab: Int = 0
    @Namespace private var animation
    
    @State private var selectedWorkout: Workout?
    @State private var selectedExercise: Exercise?
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack(alignment: .leading) {
                    ContainerViewHeader(
                        title: "Workout Stats",
                        trailingItems: {
                            NavigationLink {
                                WorkoutLogList()
                            } label: {
                                Image(systemName: "list.bullet.clipboard")
                                    .padding(.horizontal, 5)
                                    .font(Font.system(size: 20))
                            }
                            .textColor()
                            .animatedButton()
                        }
                    )
                    
                    VStack(alignment: .leading, spacing: 20) {
                        if show {
                            TabSelector(
                                tabs: ["OVERALL", "BY WORKOUT", "BY EXERCISE"],
                                selected: $selectedTab,
                                animation: animation
                            )
                            
                            TabSwipeContainer(
                                selectedTab: selectedTab,
                                content: [
                                    AnyView(OverallWorkoutStats()),
                                    AnyView(
                                        ByWorkoutStats(
                                            selectedTab: $selectedTab,
                                            workout: $selectedWorkout,
                                            exercise: $selectedExercise
                                        )
                                    ),
                                    AnyView(
                                        ByExerciseStats(
                                            selectedTab: $selectedTab,
                                            exercise: $selectedExercise,
                                            workout: $selectedWorkout
                                        )
                                    )
                                ]
                            )
                        } else {
                            EmptyState(
                                message: "No Data",
                                size: 18
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
