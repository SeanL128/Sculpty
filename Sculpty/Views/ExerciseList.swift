//
//  ExerciseList.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/18/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct ExerciseList: View {
    @Environment(\.modelContext) var context
    
    @Query private var exercises: [Exercise]
    
    @State var exerciseToDelete: Exercise? = nil
    
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
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    HStack {
                        Text("Exercises")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        NavigationLink(destination: AddExercise()) {
                            Image(systemName: "plus")
                        }
                    }
                    .padding()
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search exercises", text: $searchText)
                            .foregroundColor(.primary)
                            .focused($isSearchFocused)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                            .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                    )
                    
                    List {
                        ForEach(MuscleGroup.allCases, id: \.id) { muscleGroup in
                            if let exercisesForGroup = groupedExercises[muscleGroup], !exercisesForGroup.isEmpty {
                                Section {
                                    ForEach(exercisesForGroup) { exercise in
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
                                            
                                            NavigationLink(destination: EditExercise(exercise: exercise)) {
                                            }
                                        }
                                        .swipeActions {
                                            Button("Delete") {
                                                exerciseToDelete = exercise
                                            }
                                            .tint(.red)
                                        }
                                    }
                                } header: {
                                    Text(muscleGroup.rawValue.capitalized)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .confirmationDialog("Delete \(exerciseToDelete?.name ?? "exercise")? This will also delete all related sets.", isPresented: Binding(
                        get: { exerciseToDelete != nil },
                        set: { if !$0 { exerciseToDelete = nil } }
                    ), titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            do {
                                if let exercise = exerciseToDelete {
                                    let exerciseLogs = try context.fetch(FetchDescriptor<ExerciseLog>()).filter { $0.exercise.exercise != nil && $0.exercise.exercise! == exercise };
                                    for exerciseLog in exerciseLogs {
                                        context.delete(exerciseLog)
                                    }
                                    
                                    let workoutExercises = try context.fetch(FetchDescriptor<WorkoutExercise>()).filter { $0.exercise != nil && $0.exercise! == exercise };
                                    for workoutExercise in workoutExercises {
                                        context.delete(workoutExercise)
                                    }
                                    
                                    context.delete(exercise)
                                    try context.save()

                                    exerciseToDelete = nil
                                }
                            } catch {
                                print("Error deleting exercise: \(error)")
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
    }
}

#Preview {
    ExerciseList()
}
