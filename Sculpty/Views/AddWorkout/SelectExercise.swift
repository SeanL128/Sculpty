//
//  SelectExercise.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/14/25.
//

import SwiftUI
import SwiftData

struct SelectExercise: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
        
    @Query private var exercises: [Exercise]
    
    @Binding var selectedExercise: Exercise?
    @Binding var selectingExercise: Bool
    
    @State private var searchText: String = ""
    
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
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                List {
                    ForEach(MuscleGroup.allCases, id: \.id) { muscleGroup in
                        if let exercisesForGroup = groupedExercises[muscleGroup], !exercisesForGroup.isEmpty {
                            Section {
                                ForEach(exercisesForGroup) { exercise in
                                    Button {
                                        selectedExercise = exercise
                                        selectingExercise = false
                                    } label: {
                                        HStack {
                                            VStack {
                                                Text(exercise.name)
                                                
                                                if exercise.notes != "" {
                                                    Text(exercise.notes)
                                                        .font(.subheadline)
                                                        .italic()
                                                        .lineLimit(1)
                                                        .truncationMode(.tail)
                                                        .opacity(0.8)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            if selectedExercise == exercise {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                    .textColor()
                                }
                            } header: {
                                Text(muscleGroup.rawValue.capitalized)
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem (placement: .topBarLeading) {
                        Button {
                            selectingExercise = false
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                    
                    ToolbarItem (placement: .topBarTrailing) {
                        NavigationLink(destination: AddExercise()) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search exercises")
                .navigationTitle(Text("Select Exercise"))
            }
        }
    }
}
