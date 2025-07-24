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
    private var sortedExercises: [WorkoutExercise] { exercises.sorted { $0.index < $1.index } }
    
    @State private var confirmDelete: Bool = false
    @State private var stayOnPage: Bool = true
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    @State private var editing: Bool = false
    
    private var isValid: Bool {
        !workoutName.isEmpty && exercises.filter { $0.exercise != nil }.count > 0
    }
    
    @State private var hasUnsavedChanges: Bool = false
    @State private var originalExerciseIndices: [UUID: Int] = [:]
    
    @State private var dismissTrigger: Int = 0
    
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
        CustomActionContainerView(
            title: "\(workout == nil ? "Add" : "Edit") Workout",
            spacing: 20,
            onDismiss: {
                if hasUnsavedChanges {
                    dismissTrigger += 1
                    
                    Popup.show(content: {
                        ConfirmationPopup(
                            selection: $stayOnPage,
                            promptText: "Unsaved Changes",
                            resultText: "Are you sure you want to leave without saving?",
                            cancelText: "Discard Changes",
                            confirmText: "Stay on Page"
                        )
                    })
                } else {
                    dismiss()
                }
            }, trailingItems: {
                if let workout = workout {
                    Button {
                        cleanExercises()
                        copyWorkout()
                        hasUnsavedChanges = false
                        dismiss()
                    } label: {
                        Image(systemName: "document.on.document")
                            .padding(.horizontal, 5)
                            .font(Font.system(size: 20))
                    }
                    .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
                    .disabled(!isValid)
                    .animatedButton(feedback: .impact(weight: .light), isValid: isValid)
                    .animation(.easeInOut(duration: 0.2), value: isValid)
                    
                    Button {
                        Popup.show(content: {
                            ConfirmationPopup(
                                selection: $confirmDelete,
                                promptText: "Delete \(workout.name)?",
                                resultText: "This cannot be undone.",
                                cancelText: "Cancel",
                                confirmText: "Delete"
                            )
                        })
                    } label: {
                        Image(systemName: "trash")
                            .padding(.horizontal, 5)
                            .font(Font.system(size: 20))
                    }
                    .textColor()
                    .animatedButton(feedback: .warning)
                    .onChange(of: confirmDelete) {
                        if confirmDelete {
                            workout.hide()
                            
                            do {
                                try context.save()
                            } catch {
                                debugLog("Error: \(error.localizedDescription)")
                            }
                            
                            hasUnsavedChanges = false
                            
                            dismiss()
                        }
                    }
                }
            }
        ) {
            Input(
                title: "Name",
                text: $workoutName,
                isFocused: _isNameFocused,
                autoCapitalization: .words
            )
            .frame(maxWidth: 250)
            
            if sortedExercises.count > 0 {
                HStack(alignment: .center) {
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            editing.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.up.chevron.down")
                            .padding(.horizontal, 8)
                            .font(Font.system(size: 18))
                    }
                    .foregroundStyle(editing ? Color.accentColor : ColorManager.text)
                }
            }
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(exercises.sorted { $0.index < $1.index }, id: \.id) { exercise in
                    if let index = exercises.firstIndex(of: exercise) {
                        HStack(alignment: .center) {
                            if editing {
                                ReorderControls(
                                    moveUp: {
                                        if let above = sortedExercises.last(where: { $0.index < exercise.index }) {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                let index = exercise.index
                                                exercise.index = above.index
                                                above.index = index
                                            }
                                            
                                            hasUnsavedChanges = true
                                        }
                                    },
                                    moveDown: {
                                        if let below = sortedExercises.first(where: { $0.index > exercise.index }) {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                let index = exercise.index
                                                exercise.index = below.index
                                                below.index = index
                                            }
                                            
                                            hasUnsavedChanges = true
                                        }
                                    },
                                    canMoveUp: sortedExercises.last(where: { $0.index < exercise.index }) != nil,
                                    canMoveDown: sortedExercises.first(where: { $0.index > exercise.index }) != nil
                                )
                            }
                            
                            NavigationLink {
                                ExerciseInfo(
                                    workout: workout ?? Workout(
                                        name: workoutName,
                                        exercises: exercises,
                                        notes: workoutNotes
                                    ),
                                    exercise: exercise.exercise,
                                    workoutExercise: exercise,
                                    onChangesMade: {
                                        hasUnsavedChanges = true
                                    }
                                )
                            } label: {
                                HStack(alignment: .center) {
                                    Text(exercise.exercise?.name ?? "Select Exercise")
                                        .bodyText(size: 18, weight: .bold)
                                        .multilineTextAlignment(.leading)
                                        .animation(.easeInOut(duration: 0.3), value: exercise.exercise?.name)
                                        
                                    Image(systemName: "chevron.right")
                                        .padding(.leading, -2)
                                        .font(Font.system(size: 12, weight: .bold))
                                }
                            }
                            .textColor()
                            .animatedButton(scale: 0.98)
                            
                            Spacer()
                            
                            Button {
                                _ = withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    exercises.remove(at: index)
                                }
                                
                                hasUnsavedChanges = true
                            } label: {
                                Image(systemName: "xmark")
                                    .padding(.horizontal, 8)
                                    .font(Font.system(size: 16))
                            }
                            .textColor()
                            .animatedButton(feedback: .impact(weight: .medium))
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .leading)),
                    removal: .opacity.combined(with: .move(edge: .trailing))
                ))
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: editing)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: exercises.count)
            
            Button {
                let nextIndex = (exercises.map { $0.index }.max() ?? -1) + 1
                let newExercise = WorkoutExercise(index: nextIndex)
                
                if let existingWorkout = workout {
                    newExercise.workout = existingWorkout
                }
                
                context.insert(newExercise)
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    exercises.append(newExercise)
                }
                
                hasUnsavedChanges = true
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "plus")
                        .font(Font.system(size: 12, weight: .bold))
                    
                    Text("Add Exercise")
                        .bodyText(size: 16, weight: .bold)
                }
            }
            .textColor()
            .animatedButton(feedback: .impact(weight: .light))
            
            Spacer()
                .frame(height: 5)
            
            Input(title: "Notes", text: $workoutNotes, isFocused: _isNotesFocused, axis: .vertical)
            
            Spacer()
                .frame(height: 5)
            
            SaveButton(save: save, isValid: isValid, size: 20)
        }
        .onAppear {
            if exercises.isEmpty && workout == nil {
                let newExercise = WorkoutExercise(index: 0)
                
                context.insert(newExercise)
                
                exercises.append(newExercise)
            }
            
            originalExerciseIndices = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0.index) })
        }
        .onChange(of: workoutName) { hasUnsavedChanges = true }
        .onChange(of: workoutNotes) { hasUnsavedChanges = true }
        .onChange(of: stayOnPage) {
            if !stayOnPage {
                discardChanges()
                
                dismiss()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
        .sensoryFeedback(.warning, trigger: dismissTrigger)
        .disableEdgeSwipe(hasUnsavedChanges)
    }
    
    private func cleanExercises() {
        let exercisesToDelete = exercises.filter { $0.exercise == nil }
        
        for exercise in exercisesToDelete {
            context.delete(exercise)
        }
        
        exercises.removeAll { $0.exercise == nil }
    }
    
    private func save() {
        var blanks: [Int] = []
        var exercisesToSave = exercises
        
        for exercise in exercisesToSave where exercise.exercise == nil {
            blanks.append(exercise.index)
            
            if let index = exercisesToSave.firstIndex(of: exercise) {
                exercisesToSave.remove(at: index)
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
            
            for exercise in exercises where !existingIds.contains(exercise.id) {
                exercise.workout = workout
                
                context.insert(exercise)
                
                workout.exercises.append(exercise)
            }
        } else {
            var index = -1
            
            do {
                index = (try context.fetch(FetchDescriptor<Workout>()).map { $0.index }.max() ?? -1) + 1
            } catch {
                debugLog(error.localizedDescription)
                
                return
            }
            
            let workout = Workout(
                name: workoutName,
                exercises: exercisesToSave,
                notes: workoutNotes
            )
            workout.index = index
            
            context.insert(workout)
        }

        do {
            try context.save()
        } catch {
            debugLog("Failed to save workout: \(error.localizedDescription)")
        }
        
        originalExerciseIndices = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0.index) })
        
        hasUnsavedChanges = false
        dismiss()
    }
    
    private func copyWorkout() {
        if workout != nil {
            var index = -1
            
            do {
                index = (try context.fetch(FetchDescriptor<Workout>()).map { $0.index }.max() ?? -1) + 1
            } catch {
                debugLog(error.localizedDescription)
                
                return
            }
            
            let workoutCopy = Workout(
                index: index,
                name: "Copy of \(workoutName)",
                exercises: [],
                notes: workoutNotes
            )

            for exercise in exercises {
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
    
    private func discardChanges() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for (exerciseId, originalIndex) in originalExerciseIndices {
                if let exercise = exercises.first(where: { $0.id == exerciseId }) {
                    exercise.index = originalIndex
                }
            }
            
            context.rollback()
            
            if let workout = workout {
                workoutName = workout.name
                workoutNotes = workout.notes
                exercises = workout.exercises
            } else {
                workoutName = ""
                workoutNotes = ""
                exercises = []
            }
            
            hasUnsavedChanges = false
        }
    }
}
