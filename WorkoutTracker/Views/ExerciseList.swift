//
//  ExerciseList.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/18/25.
//

import SwiftUI
import SwiftData

struct ExerciseList: View {
    @Environment(\.modelContext) var context
    
    @Query var exercises: [Exercise]
    
    @State var delete: (Bool, Exercise) = (false, Exercise())
    
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
            exercises.sorted { $0.name.lowercased() < $1.name.lowercased() }
        }
    }
    
    var body: some View {
        NavigationStack {
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
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, -10)
                
                List {
                    ForEach(MuscleGroup.allCases, id: \.self) { muscleGroup in
                        if let exercisesForGroup = groupedExercises[muscleGroup], !exercisesForGroup.isEmpty {
                            Section(header: Text(muscleGroup.rawValue.capitalized)) {
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
                                            delete.0 = true
                                            delete.1 = exercise
                                        }
                                        .tint(.red)
                                    }
                                }
                            }
                        }
                    }
                }
                .backgroundStyle(.clear)
                .confirmationDialog("Are you sure?", isPresented: $delete.0) {
                    Button("Delete \(delete.1.name)?", role: .destructive) {
                        context.delete(delete.1)
                        try? context.save()

                        delete.0 = false
                        delete.1 = Exercise()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ExerciseList()
}
