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
    
    @Query(filter: #Predicate<Workout> { $0.index >= 0 && !$0.hidden }, sort: \.index) private var workouts: [Workout]
    
    @Binding var selectedWorkout: Workout?
    
    var forStats: Bool = false
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    var filteredWorkouts: [Workout] {
        if searchText.isEmpty {
            return workouts
        } else {
            return workouts.filter { workout in
                workout.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        ContainerView(title: "Select Workout", spacing: 16, showScrollBar: true, lazy: true, trailingItems: {
            if !forStats {
                NavigationLink {
                    UpsertWorkout()
                } label: {
                    Image(systemName: "plus")
                        .padding(.horizontal, 5)
                        .font(Font.system(size: 20))
                }
                .textColor()
                .animatedButton()
            }
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
                .padding(.bottom, 5)
            
            ForEach(filteredWorkouts.sorted { $0.index < $1.index }, id: \.id) { workout in
                SelectWorkoutRow(workout: workout, forStats: forStats, selectedWorkout: $selectedWorkout)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    ))
            }
            .animation(.easeInOut(duration: 0.3), value: filteredWorkouts.count)
        }
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
