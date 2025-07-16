//
//  SelectExercise.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/14/25.
//

import SwiftUI
import SwiftData

struct SelectExercise: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
        
    @Query(filter: #Predicate<Exercise> { !$0.hidden }) private var exercises: [Exercise]
    private var exerciseOptions: [Exercise] {
        if forStats {
            return exercises.filter { !$0.workoutExercises.compactMap { $0.exerciseLogs }.isEmpty }
        } else {
            return exercises
        }
    }
    
    @Binding var selectedExercise: Exercise?
    
    var forStats: Bool = false
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    @State private var addButtonPressed: Bool = false
    
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
        ContainerView(title: "Select Exercise", spacing: 16, showScrollBar: true, lazy: true, trailingItems: {
            if !forStats {
                NavigationLink {
                    PageRenderer(page: .upsertExercise, selectedExercise: $selectedExercise)
                } label: {
                    Image(systemName: "plus")
                        .padding(.horizontal, 5)
                        .font(Font.system(size: 20))
                }
                .textColor()
                .animatedButton()
            }
        }) {
            TextField("Search Exercises", text: $searchText)
                .focused($isSearchFocused)
                .textFieldStyle(
                    UnderlinedTextFieldStyle(
                        isFocused: Binding<Bool>(
                            get: { isSearchFocused },
                            set: { isSearchFocused = $0 }
                        ),
                        text: $searchText
                    )
                )
                .padding(.bottom, 5)
            
            if filteredExercises.isEmpty {
                HStack(alignment: .center) {
                    Spacer()
                    
                    Text("No results")
                        .bodyText(size: 18)
                        .textColor()
                        .transition(.scale.combined(with: .opacity))
                    
                    Spacer()
                }
            } else {
                ForEach(MuscleGroup.displayOrder, id: \.id) { muscleGroup in
                    if let exercisesForGroup = groupedExercises[muscleGroup], !exercisesForGroup.isEmpty {
                        ExerciseListGroup(
                            muscleGroup: muscleGroup,
                            exercises: exercisesForGroup,
                            selectedExercise: $selectedExercise,
                            exerciseOptions: exerciseOptions
                        )
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: groupedExercises)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: searchText)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: filteredExercises.isEmpty)
        .onChange(of: selectedExercise) {
            if selectedExercise != nil {
                dismiss()
            }
        }
    }
}
