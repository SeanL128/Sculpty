//
//  SelectWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/27/25.
//

import SwiftUI
import SwiftData

struct SelectWorkout: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Workout> { $0.index >= 0 && !$0.hidden }) private var workouts: [Workout]
    
    @Binding var selectedWorkout: Workout?
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
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
        ContainerView(title: "Workouts", spacing: .spacingL, lazy: true) {
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
                    subtext: searchText.isEmpty ? "Log your first workout to view stats" : "Try adjusting your search"
                )
            } else {
                VStack(alignment: .leading, spacing: .listSpacing) {
                    ForEach(filteredWorkouts, id: \.id) { workout in
                        SelectWorkoutRow(workout: workout, selectedWorkout: $selectedWorkout)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .leading)),
                                removal: .opacity.combined(with: .move(edge: .trailing))
                            ))
                    }
                    .animation(.easeInOut(duration: 0.3), value: filteredWorkouts.count)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: searchText)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
        .onChange(of: selectedWorkout) {
            if selectedWorkout != nil {
                dismiss()
            }
        }
    }
}
