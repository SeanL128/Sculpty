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
        
    @Query private var exercises: [Exercise]
    
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
            exercises.sorted { $0.name.lowercased() < $1.name.lowercased() } // Sorting exercises alphabetically by name
        }
    }
    
    var body: some View {
        ContainerView(title: "Exercises", spacing: 16, trailingItems: {
            NavigationLink(destination: UpsertExercise()) {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding(.horizontal, 3)
            }
            .textColor()
        }) {
            TextField("Search Exercises", text: $searchText)
                .focused($isSearchFocused)
                .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isSearchFocused }, set: { isSearchFocused = $0 }), text: $searchText))
                .padding(.bottom, 5)
            
            ForEach(MuscleGroup.allCases, id: \.self) { muscleGroup in
                VStack(alignment: .leading, spacing: 9) {
                    if let exercisesForGroup = groupedExercises[muscleGroup], !exercisesForGroup.isEmpty {
                        Text(muscleGroup.rawValue.uppercased())
                            .headingText(size: 14)
                            .textColor()
                            .padding(.bottom, -2)
                        
                        ForEach(exercisesForGroup) { exercise in
                            HStack(alignment: .center) {
                                Text(exercise.name)
                                    .bodyText(size: 16)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                NavigationLink(destination: UpsertExercise(exercise: exercise)) {
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                }
                            }
                            .textColor()
                            .padding(.trailing, 1)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup (placement: .keyboard) {
                Spacer()
                
                Button {
                    isSearchFocused = false
                } label: {
                    Text("Done")
                }
                .disabled(!isSearchFocused)
            }
        }
    }
}
