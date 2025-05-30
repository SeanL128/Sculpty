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
        ContainerView(title: "Exercises", spacing: 16, showScrollBar: true, trailingItems: {
            NavigationLink(destination: UpsertExercise()) {
                Image(systemName: "plus")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 20))
            }
            .textColor()
        }) {
            TextField("Search Exercises", text: $searchText)
                .focused($isSearchFocused)
                .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isSearchFocused }, set: { isSearchFocused = $0 }), text: $searchText))
                .padding(.bottom, 5)
            
            ForEach(MuscleGroup.displayOrder, id: \.self) { muscleGroup in
                if let exercisesForGroup = groupedExercises[muscleGroup], !exercisesForGroup.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(muscleGroup.rawValue.uppercased())
                            .headingText(size: 14)
                            .textColor()
                            .padding(.bottom, -8)
                        
                        ForEach(exercisesForGroup) { exercise in
                            HStack(alignment: .center) {
                                Text(exercise.name)
                                    .bodyText(size: 16)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                NavigationLink(destination: UpsertExercise(exercise: exercise)) {
                                    Image(systemName: "pencil")
                                        .padding(.horizontal, 8)
                                        .font(Font.system(size: 16))
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
                
                KeyboardDoneButton(focusStates: [_isSearchFocused])
            }
        }
    }
}
