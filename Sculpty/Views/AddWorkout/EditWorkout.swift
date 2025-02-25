//
//  AddWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/25/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct EditWorkout: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    
    @Query private var workouts: [Workout]
    
    @State var workout: Workout
    
    @State private var alertType: AlertType? = nil

    enum AlertType: Identifiable {
        case title, exercises
        
        var id: Int {
            switch self {
            case .title: return 0
            case .exercises: return 1
            }
        }
    }
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    init(workout: Workout) {
        self._workout = State(initialValue: workout)
        
        workout.exercises.removeAll { $0.exercise == nil }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    TextField("Workout Name", text: $workout.name)
                        .textInputAutocapitalization(.words)
                        .focused($isNameFocused)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                        )
                    
                    List {
                        ForEach(workout.exercises.sorted { $0.index < $1.index }, id: \.id) { exercise in
                            let index = workout.exercises.firstIndex(of: exercise)!
                            HStack {
                                Text(exercise.exercise?.name ?? "Select Exercise")
                                NavigationLink(destination: ExerciseInfo(workout: workout, exercise: exercise.exercise ?? nil, workoutExercise: $workout.exercises[index])) {
                                }
                            }
                            .swipeActions {
                                Button("Delete") {
                                    workout.exercises.remove(at: index)
                                }
                                .tint(.red)
                            }
                        }
                        .onMove { from, to in
                            var reordered = workout.exercises
                            
                            reordered.move(fromOffsets: from, toOffset: to)
                            
                            for (newIndex, exercise) in reordered.enumerated() {
                                if exercise.index != newIndex {
                                    exercise.index = newIndex
                                }
                            }
                            
                            workout.exercises = reordered
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                    Button {
                        let nextIndex = (workout.exercises.map { $0.index }.max() ?? -1) + 1
                        workout.exercises.append(WorkoutExercise(index: nextIndex))
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Exercise")
                        }
                    }
                    
                    
                    TextField("Notes", text: $workout.notes, axis: .vertical)
                        .focused($isNotesFocused)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                        )
                    
                    
                    Button {
                        guard !workout.name.isEmpty else {
                            alertType = .title
                            return
                        }
                        
                        var blanks: [Int] = []
                        for exercise in workout.exercises {
                            if exercise.exercise == nil {
                                blanks.append(exercise.index)
                                workout.exercises.remove(at: workout.exercises.firstIndex(of: exercise)!)
                            }
                        }
                        
                        guard workout.exercises.count > 0 else {
                            for index in blanks {
                                workout.exercises.append(WorkoutExercise(index: index))
                            }
                            
                            alertType = .exercises
                            return
                        }
                        
                        context.insert(workout)
                        context.insert(WorkoutLog(workout: workout))

                        try? context.save()
                        
                        dismiss()
                    } label: {
                        HStack {
                            Text("Save")
                        }
                    }
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .navigationTitle("Edit Workout")
                .alert(item: $alertType) { type in
                    switch type {
                    case .title:
                        return Alert(title: Text("Error"), message: Text("Please name this workout."))
                    case .exercises:
                        return Alert(title: Text("Error"), message: Text("Please add at least one exercise."))
                    }
                }
                .toolbar {
                    ToolbarItemGroup (placement: .keyboard) {
                        Spacer()
                        
                        Button {
                            isNameFocused = false
                            isNotesFocused = false
                        } label: {
                            Text("Done")
                        }
                        .disabled(!(isNameFocused || isNotesFocused))
                    }
                }
            }
            .onDisappear {
                workout.exercises.removeAll { $0.exercise == nil }
            }
        }
    }
}

#Preview {
    EditWorkout(workout: Workout())
}
