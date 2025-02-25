//
//  SelectWorkouts.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/17/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct SelectWorkouts: View {
    @Environment(\.modelContext) private var context
    
    @Query(filter: #Predicate<Workout> { $0.index >= 0 }, sort: \.index) private var workouts: [Workout]
    
    @State private var showAddWorkoutSheet: Bool = false
    
    let day: ScheduleDay
    
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
                        
                        HStack {
                            Text("Rest Day")

                            Toggle("", isOn: Binding(
                                get: { day.restDay },
                                set: { newValue in
                                    day.restDay = !day.restDay
                                }
                            ))
                            .labelsHidden()
                        }
                        .padding(.horizontal)
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
                            
                            if workouts.count > 0 {
                                Divider()
                                    .background(ColorManager.text)
                            }
                            
                            ForEach(workouts, id: \.self) { workout in
                                VStack {
                                    HStack {
                                        Text(workout.name)
                                            .font(.title3)
                                        
                                        Spacer()
                                        
                                        if day.workouts.contains(workout) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.accentColor)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(ColorManager.text)
                                        }
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
                                    toggleSelection(workout)
                                }
                                
                                if workout != workouts.last {
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
    
    private func toggleSelection(_ workout: Workout) {
        if day.workouts.contains(workout) {
            day.removeWorkout(workout)
        } else {
            day.addWorkout(workout)
        }
    }
}
