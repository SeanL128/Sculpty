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
    
    private var isValid: Bool {
        !workoutName.isEmpty && !exercises.filter { $0.exercise != nil }.isEmpty
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
            spacing: .spacingXXL,
            onDismiss: {
                if hasUnsavedChanges {
                    dismissTrigger += 1
                    
                    Popup.show(content: {
                        ConfirmationPopup(
                            selection: $stayOnPage,
                            promptText: "Unsaved Changes",
                            resultText: "Are you sure you want to leave without saving?",
                            cancelText: "Discard Changes",
                            cancelColor: ColorManager.destructive,
                            cancelFeedback: .impact(weight: .medium),
                            confirmText: "Stay on Page",
                            confirmColor: ColorManager.text,
                            confirmFeedback: .selection
                        )
                    })
                } else {
                    cleanExercises()
                    
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
                            .pageTitleImage()
                    }
                    .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
                    .disabled(!isValid)
                    .animatedButton(isValid: isValid)
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
                            .pageTitleImage()
                    }
                    .textColor()
                    .animatedButton(feedback: .warning)
                    .onChange(of: confirmDelete) {
                        if confirmDelete {
                            workout.hide()
                            
                            do {
                                let logs = try context.fetch(FetchDescriptor<WorkoutLog>())
                                    .filter { $0.workout == workout && $0.started }
                                
                                if logs.isEmpty {
                                    context.delete(workout)
                                }
                                
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
            VStack(alignment: .leading, spacing: .spacingXL) {
                Input(
                    title: "Name",
                    text: $workoutName,
                    isFocused: _isNameFocused,
                    autoCapitalization: .words
                )
                
                if !exercises.isEmpty {
                    VStack(alignment: .leading, spacing: .listSpacing) {
                        ForEach(exercises.sorted { $0.index < $1.index }, id: \.id) { exercise in
                            if let index = exercises.firstIndex(of: exercise) {
                                HStack(alignment: .center, spacing: .spacingM) {
                                    ReorderControls(
                                        moveUp: {
                                            if let above = sortedExercises.last(where: { $0.index < exercise.index }) { // swiftlint:disable:this line_length
                                                let index = exercise.index
                                                exercise.index = above.index
                                                above.index = index
                                                
                                                hasUnsavedChanges = true
                                            }
                                        },
                                        moveDown: {
                                            if let below = sortedExercises.first(where: { $0.index > exercise.index }) { // swiftlint:disable:this line_length
                                                let index = exercise.index
                                                exercise.index = below.index
                                                below.index = index
                                                
                                                hasUnsavedChanges = true
                                            }
                                        },
                                        canMoveUp: sortedExercises.last(where: { $0.index < exercise.index }) != nil, // swiftlint:disable:this line_length
                                        canMoveDown: sortedExercises.first(where: { $0.index > exercise.index }) != nil // swiftlint:disable:this line_length
                                    )
                                    
                                    NavigationLink {
                                        ExerciseInfo(
                                            exercise: exercise.exercise,
                                            workoutExercise: exercise,
                                            onChangesMade: {
                                                hasUnsavedChanges = true
                                            }
                                        )
                                    } label: {
                                        HStack(alignment: .center, spacing: .spacingXS) {
                                            Text(exercise.exercise?.name ?? "Select Exercise")
                                                .bodyText()
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                                .multilineTextAlignment(.leading)
                                                .animation(.easeInOut(duration: 0.3), value: exercise.exercise?.name)
                                                
                                            Image(systemName: "chevron.right")
                                                .bodyImage()
                                        }
                                    }
                                    .textColor()
                                    .animatedButton(feedback: .selection)
                                    
                                    Spacer()
                                    
                                    Button {
                                        _ = withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            exercises.remove(at: index)
                                        }
                                        
                                        hasUnsavedChanges = true
                                    } label: {
                                        Image(systemName: "xmark")
                                            .bodyText(weight: .regular)
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
                }
                
                Button {
                    let nextIndex = (exercises.map { $0.index }.max() ?? -1) + 1
                    let newExercise = WorkoutExercise(index: nextIndex)
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        exercises.append(newExercise)
                    }
                    
                    hasUnsavedChanges = true
                } label: {
                    HStack(alignment: .center, spacing: .spacingXS) {
                        Image(systemName: "plus")
                            .secondaryImage(weight: .bold)
                        
                        Text("Add Exercise")
                            .secondaryText()
                    }
                }
                .textColor()
                .animatedButton()
                
                Input(title: "Notes", text: $workoutNotes, isFocused: _isNotesFocused, axis: .vertical)
            }
            
            HStack(alignment: .center) {
                Spacer()
                
                SaveButton(save: save, isValid: isValid)
                
                Spacer()
            }
        }
        .onAppear {
            if exercises.isEmpty && workout == nil {
                let newExercise = WorkoutExercise(index: 0)
                
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
        let validExercises = exercises.filter { $0.exercise != nil }
            
        guard !validExercises.isEmpty else { return }
        
        cleanExercises()
        
        if let workout = workout {
            workout.name = workoutName
            workout.notes = workoutNotes
            
            let existingIds = Set(workout.exercises.map { $0.id })
            let updatedIds = Set(exercises.map { $0.id })
            
            workout.exercises.removeAll(where: { !updatedIds.contains($0.id) })
            
            for exercise in exercises where !existingIds.contains(exercise.id) {
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
                exercises: validExercises,
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
