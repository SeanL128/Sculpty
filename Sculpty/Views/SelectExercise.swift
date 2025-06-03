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
        ContainerView(title: "Select Exercise", spacing: 16, showScrollBar: true, trailingItems: {
            if !forStats {
                NavigationLink(destination: PageRenderer(page: .upsertExercise)) {
                    Image(systemName: "plus")
                        .padding(.horizontal, 5)
                        .font(Font.system(size: 20))
                }
                .textColor()
            }
        }) {
            TextField("Search Exercises", text: $searchText)
                .focused($isSearchFocused)
                .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isSearchFocused }, set: { isSearchFocused = $0 }), text: $searchText))
                .padding(.bottom, 5)
            
            ForEach(MuscleGroup.displayOrder, id: \.id) { muscleGroup in
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
                                        .bodyText(size: 16, weight: selectedExercise == exercise ? .bold : .regular)
                                        .multilineTextAlignment(.leading)
                                    
                                    if exerciseOptions.contains(where: { $0 == exercise }) {
                                        Image(systemName: "chevron.right")
                                            .padding(.leading, -2)
                                            .font(Font.system(size: 10, weight: selectedExercise == exercise ? .bold : .regular))
                                    }
                                    
                                    if selectedExercise == exercise {
                                        Spacer()
                                        
                                        Image(systemName: "checkmark")
                                            .padding(.horizontal, 8)
                                            .font(Font.system(size: 16))
                                    }
                                }
                            }
                            .foregroundStyle(forStats && !exerciseOptions.contains(where: { $0.id == exercise.id }) ? ColorManager.secondary : ColorManager.text)
                            .disabled(forStats && !exerciseOptions.contains(where: { $0.id == exercise.id }))
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup (placement: .keyboard) {
                Spacer()
                
                KeyboardDoneButton(focusStates: [_isSearchFocused])
            }
        }
        .onChange(of: selectedExercise) {
            if selectedExercise != nil {
                dismiss()
            }
        }
    }
}
