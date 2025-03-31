//
//  WorkoutList.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/24/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct WorkoutList: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Workout> { $0.index >= 0 }, sort: \.index) private var workouts: [Workout]
    
    @Binding var workoutToStart: WorkoutLog?
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    HStack {
                        Text("WORKOUTS")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        NavigationLink(destination: AddWorkout()) {
                            HStack {
                                Image(systemName: "plus")
                                
                                Text("ADD WORKOUT")
                            }
                        }
                        
                        Divider()
                            .background(ColorManager.text)
                        
                        ForEach(workouts, id: \.self) { workout in
                            VStack {
                                HStack {
                                    Text(workout.name)
                                        .font(.title3)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: AddWorkout(workout: workout)) {
                                        Image(systemName: "pencil")
                                            .padding(.horizontal, 5)
                                    }
                                    
                                    Button {
                                        let log = WorkoutLog(workout: workout)
                                        
                                        context.insert(log)
                                        workoutToStart = log
                                        dismiss()
                                    } label: {
                                        Image(systemName: "play.fill")
                                            .padding(.horizontal, 5)
                                    }
                                }
                                
//                                if !workout.exercises.isEmpty {
//                                    VStack(alignment: .leading) {
//                                        ForEach(workout.exercises, id: \.self) { exercise in
//                                            HStack {
//                                                Text(exercise.exercise?.name ?? "Exercise \(exercise.index)")
//                                                
//                                                Spacer()
//                                            }
//                                            .frame(maxWidth: .infinity)
//                                        }
//                                    }
//                                    .padding(.top, 3)
//                                    .padding(.leading, 20)
//                                }
                            }
                            .padding(.bottom, 12)
                        }
                    }
                    .padding()
                }
                .padding()
                .scrollClipDisabled()
            }
        }
    }
}
