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
    
    @Query(filter: #Predicate<Workout> { $0.index >= 0 && !$0.hidden }, sort: \.index) private var workouts: [Workout]
    
    @Binding var workoutToStart: WorkoutLog?
    
    @State private var editing: Bool = false
    
    var body: some View {
        ContainerView(title: "Workouts", spacing: 16, showScrollBar: true, lazy: true, trailingItems: {
            NavigationLink {
                PageRenderer(page: .exerciseList)
            } label: {
                Image(systemName: "figure.run")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 20))
            }
            .textColor()
            .animatedButton()
            
            NavigationLink {
                PageRenderer(page: .upsertWorkout)
            } label: {
                Image(systemName: "plus")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 20))
            }
            .textColor()
            .animatedButton()
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
                .animatedButton()
                .animation(.easeInOut(duration: 0.3), value: editing)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(workouts, id: \.id) { workout in
                    WorkoutListRow(
                        workout: workout,
                        workouts: workouts,
                        workoutToStart: $workoutToStart,
                        editing: editing
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    ))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: workouts.count)
            .animation(.easeInOut(duration: 0.3), value: workouts.sorted(by: { $0.index < $1.index }).map { $0.id })
        }
    }
}
