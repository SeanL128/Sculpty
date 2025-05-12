//
//  WorkoutList.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/24/25.
//

import SwiftUI
import SwiftData

struct WorkoutList: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Workout> { $0.index >= 0 && !$0.hidden }, sort: \.index) private var workouts: [Workout]
    
    @Binding var workoutToStart: WorkoutLog?
    
    var body: some View {
        ContainerView(title: "Workouts", spacing: 16, trailingItems: {
            NavigationLink(destination: PageRenderer(page: .exerciseList)) {
                Image(systemName: "figure.run")
                    .font(.title2)
                    .padding(.horizontal, 3)
            }
            .textColor()
            
            NavigationLink(destination: PageRenderer(page: .upsertWorkout)) {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding(.horizontal, 3)
            }
            .textColor()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(workouts, id: \.self) { workout in
                    VStack {
                        HStack {
                            Text(workout.name)
                                .bodyText(size: 18)
                            
                            Spacer()
                            
                            NavigationLink(destination: UpsertWorkout(workout: workout)) {
                                Image(systemName: "pencil")
                                    .padding(.horizontal, 8)
                            }
                            .textColor()
                            
                            Button {
                                let log = WorkoutLog(workout: workout)
                                
                                context.insert(log)
                                
                                workoutToStart = log
                                
                                dismiss()
                            } label: {
                                Image(systemName: "play.fill")
                                    .padding(.horizontal, 8)
                            }
                            .textColor()
                        }
                        
                        if let date = workout.lastStarted {
                            HStack {
                                Text("Last started: \(formatDateWithTime(date))")
                                    .bodyText(size: 12)
                                    .secondaryColor()
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}
