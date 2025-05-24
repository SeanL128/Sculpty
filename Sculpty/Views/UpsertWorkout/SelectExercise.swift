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
        
    @Query private var exercises: [Exercise]
    
    @Binding var selectedExercise: Exercise?
    
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
        ContainerView(title: "Select Exercise", spacing: 16, showScrollBar: true, trailingItems: {
            NavigationLink(destination: UpsertExercise(selectedExercise: $selectedExercise)) {
                Image(systemName: "plus")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 24))
            }
            .textColor()
        }) {
            TextField("Search Exercises", text: $searchText)
                .focused($isSearchFocused)
                .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isSearchFocused }, set: { isSearchFocused = $0 }), text: $searchText))
                .padding(.bottom, 5)
            
            ForEach(MuscleGroup.displayOrder, id: \.self) { muscleGroup in
                VStack(alignment: .leading, spacing: 9) {
                    if let exercisesForGroup = groupedExercises[muscleGroup], !exercisesForGroup.isEmpty {
                        Text(muscleGroup.rawValue.uppercased())
                            .headingText(size: 14)
                            .textColor()
                            .padding(.bottom, -2)
                        
                        ForEach(exercisesForGroup) { exercise in
                            Button {
                                selectedExercise = exercise
                            } label: {
                                HStack(alignment: .center) {
                                    Text(exercise.name)
                                        .bodyText(size: 16)
                                        .multilineTextAlignment(.leading)
                                    
                                    if selectedExercise == exercise {
                                        Spacer()
                                        
                                        Image(systemName: "checkmark")
                                            .padding(.horizontal, 8)
                                            .font(Font.system(size: 16))
                                    }
                                }
                                .textColor()
                            }
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
        .onChange(of: selectedExercise) {
            if selectedExercise != nil {
                dismiss()
            }
        }
    }
}
