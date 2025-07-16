//
//  ExerciseList.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/11/25.
//

import SwiftUI
import SwiftData

struct ExerciseList: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
        
    @Query(filter: #Predicate<Exercise> { !$0.hidden }) private var exercises: [Exercise]
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { exercise in
                exercise.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var groupedExercises: [MuscleGroup: [Exercise]] {
        Dictionary(grouping: filteredExercises, by: { exercise in
            exercise.muscleGroup ?? MuscleGroup.other
        })
        .mapValues { exercises in
            exercises.sorted { $0.name.lowercased() < $1.name.lowercased() }
        }
    }
    
    var body: some View {
        ContainerView(title: "Exercises", spacing: 16, showScrollBar: true, lazy: true, trailingItems: {
            NavigationLink {
                PageRenderer(page: .upsertExercise)
            } label: {
                Image(systemName: "plus")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 20))
            }
            .textColor()
            .animatedButton()
        }) {
            TextField("Search Exercises", text: $searchText)
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
            
            if filteredExercises.isEmpty {
                HStack(alignment: .center) {
                    Spacer()
                    
                    Text("No results")
                        .bodyText(size: 18)
                        .textColor()
                    
                    Spacer()
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                ForEach(MuscleGroup.displayOrder, id: \.id) { muscleGroup in
                    if let exercisesForGroup = groupedExercises[muscleGroup], !exercisesForGroup.isEmpty {
                        ExerciseListGroup(muscleGroup: muscleGroup, exercises: exercisesForGroup)
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: searchText)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: filteredExercises.isEmpty)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
    }
}
