//
//  SelectWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/24/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct SelectWorkout: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Workout> { $0.index >= 0 }, sort: \.index) private var workouts: [Workout]
    @Query(filter: #Predicate<WorkoutLog> { !$0.started }, sort: \WorkoutLog.workout.index) private var unstartedWorkoutLogs: [WorkoutLog]
    
    @State private var showAddWorkoutSheet: Bool = false
    
    @Binding var workoutToStart: WorkoutLog?
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Text("Workouts")
                            .font(.largeTitle)
                            .bold()
                    }
                    .padding()
                    
                    ScrollView {
                        VStack {
                            Button {
                                showAddWorkoutSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    
                                    Text("Add Workout")
                                }
                            }
                            
                            if unstartedWorkoutLogs.count > 0 {
                                Divider()
                                    .background(ColorManager.text)
                            }
                            
                            ForEach(unstartedWorkoutLogs, id: \.self) { log in
                                let workout = log.workout
                                
                                VStack {
                                    HStack {
                                        Text(workout.name)
                                            .font(.title3)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                    }
                                    
                                    if !workout.exercises.isEmpty {
                                        VStack(alignment: .leading) {
                                            ForEach(workout.exercises, id: \.self) { exercise in
                                                Text(exercise.exercise?.name ?? "Exercise \(exercise.index)")
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                                        )
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    workoutToStart = log
                                    dismiss()
                                }
                                
                                if log != unstartedWorkoutLogs.last {
                                    Divider()
                                        .background(ColorManager.text)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )
                    }
                    .padding()
                    .scrollClipDisabled()
                    .sheet(isPresented: $showAddWorkoutSheet) {
                        AddWorkout()
                    }
                }
            }
        }
    }
}
