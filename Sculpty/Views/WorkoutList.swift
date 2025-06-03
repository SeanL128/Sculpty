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
    
    @State private var editing: Bool = false
    
    var body: some View {
        ContainerView(title: "Workouts", spacing: 16, trailingItems: {
            NavigationLink(destination: PageRenderer(page: .exerciseList)) {
                Image(systemName: "figure.run")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 20))
            }
            .textColor()
            
            NavigationLink(destination: PageRenderer(page: .upsertWorkout)) {
                Image(systemName: "plus")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 20))
            }
            .textColor()
        }) {
            HStack(alignment: .center) {
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        editing.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.up.chevron.down")
                        .padding(.horizontal, 8)
                        .font(Font.system(size: 18))
                }
                .foregroundStyle(editing ? Color.accentColor : ColorManager.text)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(workouts, id: \.id) { workout in
                    HStack(alignment: .center) {
                        if editing {
                            VStack(alignment: .center, spacing: 10) {
                                Button {
                                    if let above = workouts.last(where: { $0.index < workout.index }) {
                                        let index = workout.index
                                        workout.index = above.index
                                        above.index = index
                                    }
                                } label: {
                                    Image(systemName: "chevron.up")
                                        .font(Font.system(size: 14))
                                }
                                .foregroundStyle(workouts.last(where: { $0.index < workout.index }) == nil ? ColorManager.secondary : ColorManager.text)
                                .disabled(workouts.last(where: { $0.index < workout.index }) == nil)
                                
                                Button {
                                    if let below = workouts.first(where: { $0.index > workout.index }) {
                                        let index = workout.index
                                        workout.index = below.index
                                        below.index = index
                                    }
                                } label: {
                                    Image(systemName: "chevron.down")
                                        .font(Font.system(size: 14))
                                }
                                .foregroundStyle(workouts.first(where: { $0.index > workout.index }) == nil ? ColorManager.secondary : ColorManager.text)
                                .disabled(workouts.first(where: { $0.index > workout.index }) == nil)
                            }
                        }
                        
                        VStack {
                            HStack {
                                Text(workout.name)
                                    .bodyText(size: 18)
                                
                                Spacer()
                                
                                NavigationLink(destination: UpsertWorkout(workout: workout)) {
                                    Image(systemName: "pencil")
                                        .padding(.horizontal, 8)
                                        .font(Font.system(size: 18))
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
                                        .font(Font.system(size: 18))
                                }
                                .textColor()
                            }
                            
                            HStack {
                                Text("Last started: \(workout.lastStarted != nil ? formatDateWithTime(workout.lastStarted ?? Date()) : "N/A")")
                                    .bodyText(size: 12)
                                    .secondaryColor()
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: workouts.sorted(by: { $0.index < $1.index }).map { $0.id })
        }
    }
}
