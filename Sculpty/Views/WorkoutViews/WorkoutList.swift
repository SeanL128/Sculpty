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
    
    @Query(filter: #Predicate<Workout> { $0.index >= 0 && !$0.hidden }) private var workouts: [Workout]
    
    @Binding var workoutToStart: WorkoutLog?
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    @State private var editing: Bool = false
    
    var filteredWorkouts: [Workout] {
        if searchText.isEmpty {
            return workouts
                .sorted { $0.index < $1.index }
        } else {
            return workouts
                .filter { workout in
                    workout.name.lowercased().contains(searchText.lowercased())
                }
                .sorted { $0.index < $1.index }
        }
    }
    
    var body: some View {
        ContainerView(title: "Workouts", spacing: .spacingL, lazy: true, trailingItems: {
            if searchText.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        editing.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.up.chevron.down")
                        .bodyText()
                }
                .foregroundStyle(editing ? ColorManager.accent : ColorManager.text)
                .animatedButton()
                .animation(.easeInOut(duration: 0.3), value: editing)
            }
            
            NavigationLink {
                PageRenderer(page: .exerciseList)
            } label: {
                Image(systemName: "figure.run")
                    .pageTitleImage()
            }
            .textColor()
            .animatedButton(feedback: .selection)
            
            NavigationLink {
                PageRenderer(page: .upsertWorkout)
            } label: {
                Image(systemName: "plus")
                    .pageTitleImage()
            }
            .textColor()
            .animatedButton()
        }) {
            TextField("Search Workouts", text: $searchText)
                .focused($isSearchFocused)
                .textFieldStyle(
                    UnderlinedTextFieldStyle(
                        isFocused: Binding<Bool>(
                            get: { isSearchFocused },
                            set: { isSearchFocused = $0 }
                        ),
                        text: $searchText)
                )
                .padding(.bottom, .spacingXS)
            
            if filteredWorkouts.isEmpty {
                EmptyState(
                    image: "magnifyingglass",
                    text: "No workouts found",
                    subtext: workouts.isEmpty ? "Press the + to create one" : "Try adjusting your search"
                )
            } else {
                VStack(alignment: .leading, spacing: .listSpacing) {
                    ForEach(filteredWorkouts, id: \.id) { workout in
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
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: filteredWorkouts.count)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: searchText)
    }
}
