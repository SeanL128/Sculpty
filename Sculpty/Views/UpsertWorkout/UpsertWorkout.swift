//
//  UpsertWorkout.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/25/25.
//

import SwiftUI
import SwiftData

struct UpsertWorkout: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var workout: Workout?
    
    @State private var workoutName: String
    @State private var workoutNotes: String
    @State private var exercises: [WorkoutExercise]
    
    @State private var confirmDelete: Bool = false
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    private var isValid: Bool {
        !workoutName.isEmpty && exercises.filter { $0.exercise != nil }.count > 0
    }
    
    init() {
        workoutName = ""
        workoutNotes = ""
        exercises = []
    }
    
    init (workout: Workout) {
        self.workout = workout
        
        workoutName = workout.name
        workoutNotes = workout.notes
        exercises = workout.exercises
    }
    
    var body: some View {
        ContainerView(title: "\(workout != nil ? "Edit" : "Add") Workout", spacing: 20, onDismiss: { cleanExercises() }, trailingItems: {
            if let workout = workout {
                Button {
                    cleanExercises()
                    
                    copyWorkout()
                    
                    dismiss()
                } label: {
                    Image(systemName: "document.on.document")
                        .padding(.horizontal, 5)
                        .font(Font.system(size: 20))
                }
                .textColor()
                
                Button {
                    Task {
                        await ConfirmationPopup(selection: $confirmDelete, promptText: "Delete \(workout.name)?", resultText: "This cannot be undone.", cancelText: "Cancel", confirmText: "Delete").present()
                    }
                } label: {
                    Image(systemName: "trash")
                        .padding(.horizontal, 5)
                        .font(Font.system(size: 20))
                }
                .textColor()
                .onChange(of: confirmDelete) {
                    if confirmDelete {
                        workout.hide()
                        
                        try? context.save()
                        
                        dismiss()
                    }
                }
            }
        }) {
            Input(title: "Name", text: $workoutName, isFocused: _isNameFocused, autoCapitalization: .words)
                .frame(maxWidth: 250)
                .padding(.bottom, 20)
            
            
            ForEach(exercises.sorted { $0.index < $1.index }, id: \.id) { exercise in
                if let index = exercises.firstIndex(of: exercise) {
                    HStack(alignment: .center) {
                        NavigationLink(destination: {
                            ExerciseInfo(
                                workout: workout ?? Workout(name: workoutName, exercises: exercises, notes: workoutNotes),
                                exercise: exercise.exercise,
                                workoutExercise: exercise
                            )
                        }) {
                            Text(exercise.exercise?.name ?? "Select Exercise")
                                .bodyText(size: 18, weight: .bold)
                                .multilineTextAlignment(.leading)
                                
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 12, weight: .bold))
                        }
                        .textColor()
                        
                        Spacer()
                        
                        Button {
                            exercises.remove(at: index)
                        } label: {
                            Image(systemName: "xmark")
                                .padding(.horizontal, 8)
                                .font(Font.system(size: 16))
                        }
                        .textColor()
                    }
                }
            }
            
            Button {
                let nextIndex = (exercises.map { $0.index }.max() ?? -1) + 1
                let newExercise = WorkoutExercise(index: nextIndex)
                
                if let existingWorkout = workout {
                    newExercise.workout = existingWorkout
                }
                
                context.insert(newExercise)
                exercises.append(newExercise)
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "plus")
                        .font(Font.system(size: 12, weight: .bold))
                    
                    Text("Add Exercise")
                        .bodyText(size: 16, weight: .bold)
                }
            }
            .textColor()
            
            
            Spacer()
                .frame(height: 5)
            
            
            Input(title: "Notes", text: $workoutNotes, isFocused: _isNotesFocused, axis: .vertical)
            
            
            Spacer()
                .frame(height: 5)
            
            
            Button {
                save()
            } label: {
                Text("Save")
                    .bodyText(size: 20, weight: .bold)
            }
            .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
            .disabled(!isValid)
        }
        .toolbar {
            ToolbarItemGroup (placement: .keyboard) {
                Spacer()
                
                KeyboardDoneButton(focusStates: [_isNameFocused, _isNotesFocused])
            }
        }
        .onAppear() {
            if exercises.isEmpty {
                exercises.append(WorkoutExercise(index: 0))
            }
        }
    }
    
    private func cleanExercises() {
        for exercise in exercises {
            if exercise.exercise == nil {
                context.delete(exercise)
                exercises.remove(at: exercises.firstIndex(of: exercise)!)
            }
        }
    }
    
    private func save() {
        var blanks: [Int] = []
        var exercisesToSave = exercises
        
        for exercise in exercisesToSave {
            if exercise.exercise == nil {
                blanks.append(exercise.index)
                exercisesToSave.remove(at: exercisesToSave.firstIndex(of: exercise)!)
            }
        }
        
        guard exercisesToSave.count > 0 else {
            for index in blanks {
                exercises.append(WorkoutExercise(index: index))
            }
            
            return
        }
        
        if let workout = workout {
            workout.name = workoutName
            workout.notes = workoutNotes
            
            let existingIds = Set(workout.exercises.map { $0.id })
            let updatedIds = Set(exercises.map { $0.id })
            
            workout.exercises.removeAll(where: { !updatedIds.contains($0.id) })
            
            for exercise in exercises {
                if !existingIds.contains(exercise.id) {
                    exercise.workout = workout
                    context.insert(exercise)
                    workout.exercises.append(exercise)
                }
                
                if let index = exercises.firstIndex(where: { $0.id == exercise.id }) {
                    exercise.index = index
                }
            }
        } else {
            var index = -1
            
            do {
                index = (try context.fetch(FetchDescriptor<Workout>()).map { $0.index }.max() ?? -1) + 1
            } catch {
                debugLog(error.localizedDescription)
                
                return
            }
            
            let workout = Workout(name: workoutName, exercises: exercisesToSave, notes: workoutNotes)
            workout.index = index
            
            context.insert(workout)
        }

        try? context.save()
        
        dismiss()
    }
    
    private func copyWorkout() {
        if let workout = workout {
            var index = -1
            
            do {
                index = (try context.fetch(FetchDescriptor<Workout>()).map { $0.index }.max() ?? -1) + 1
            } catch {
                debugLog(error.localizedDescription)
                
                return
            }
            
            let workoutCopy = Workout(index: index, name: "Copy of \(workout.name)", exercises: [], notes: workout.notes)
            
            for exercise in workout.exercises {
                workoutCopy.exercises.append(exercise.copy())
            }
            
            context.insert(workoutCopy)
            
            do {
                try context.save()
            } catch {
                debugLog("Failed to save workout copy: \(error.localizedDescription)")
            }
        }
    }
}
