//
//  UpsertExercise.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData

struct UpsertExercise: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var exercise: Exercise?
    
    @Binding private var selectedExercise: Exercise?
    
    @State private var exerciseName: String
    @State private var exerciseNotes: String
    
    @State private var selectedMuscleGroup: String?
    @State private var selectedExerciseType: ExerciseType
    
    @State private var confirmDelete: Bool = false
    @State private var stayOnPage: Bool = true
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    @State private var hasUnsavedChanges: Bool = false
    
    @State private var dismissTrigger: Int = 0
    
    private var isValid: Bool {
        !exerciseName.trimmingCharacters(in: .whitespaces).isEmpty && selectedMuscleGroup != nil
    }
    
    init(selectedExercise: Binding<Exercise?> = .constant(nil)) {
        exerciseName = ""
        exerciseNotes = ""
        selectedExerciseType = .weight
        
        self._selectedExercise = selectedExercise
    }
    
    init(exercise: Exercise, selectedExercise: Binding<Exercise?> = .constant(nil)) {
        self.exercise = exercise
        
        exerciseName = exercise.name
        exerciseNotes = exercise.notes
        selectedMuscleGroup = exercise.muscleGroup?.rawValue ?? "Other"
        selectedExerciseType = exercise.type
        
        self._selectedExercise = selectedExercise
    }
    
    var body: some View {
        CustomActionContainerView(
            title: "\(exercise == nil ? "Add" : "Edit") Exercise",
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
                if exercise != nil {
                    Button {
                        copyExercise()
                        dismiss()
                    } label: {
                        Image(systemName: "document.on.document")
                            .padding(.horizontal, 5)
                            .font(Font.system(size: 20))
                    }
                    .textColor()
                    .animatedButton(feedback: .impact(weight: .light))
                    
                    Button {
                        Popup.show(content: {
                            ConfirmationPopup(
                                selection: $confirmDelete,
                                promptText: "Delete \(exerciseName)?",
                                resultText: "This will also remove it from all workouts.",
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
                            do {
                                deleteExercise()
                                
                                try context.save()
                                
                                hasUnsavedChanges = false
                                
                                dismiss()
                            } catch {
                                debugLog("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        ) {
            Input(
                title: "Name",
                text: $exerciseName,
                isFocused: _isNameFocused,
                autoCapitalization: .words
            )
            .frame(maxWidth: 250)
            
            MuscleGroupMenu(selectedMuscleGroup: $selectedMuscleGroup)
            
            LabeledTypeSegmentedControl(
                label: "Tracking Type",
                size: 12,
                selection: $selectedExerciseType,
                options: ExerciseType.displayOrder,
                displayNames: ExerciseType.stringDisplayOrder
            )
            
            Spacer()
                .frame(height: 5)
            
            Input(title: "Notes", text: $exerciseNotes, isFocused: _isNotesFocused, axis: .vertical)
            
            Spacer()
                .frame(height: 5)
            
            SaveButton(save: save, isValid: isValid, size: 20)
        }
        .onChange(of: exerciseName) { hasUnsavedChanges = true }
        .onChange(of: exerciseNotes) { hasUnsavedChanges = true }
        .onChange(of: selectedMuscleGroup) { hasUnsavedChanges = true }
        .onChange(of: selectedExerciseType) { hasUnsavedChanges = true }
        .onChange(of: stayOnPage) {
            if !stayOnPage {
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
    
    private func save() {
        if let exercise = exercise {
            exercise.name = exerciseName
            exercise.notes = exerciseNotes
            exercise.muscleGroup = MuscleGroup(rawValue: selectedMuscleGroup ?? "Other") ?? .other
            exercise.type = selectedExerciseType
            
            self.exercise = exercise
        } else {
            let exercise = Exercise(
                name: exerciseName,
                notes: exerciseNotes,
                muscleGroup: MuscleGroup(
                    rawValue: selectedMuscleGroup ?? "Other"
                ) ?? .other,
                type: selectedExerciseType
            )
            
            context.insert(exercise)
            
            self.exercise = exercise
        }

        do {
            try context.save()
        } catch {
            debugLog("Error: \(error.localizedDescription)")
        }
        
        selectedExercise = self.exercise
        
        hasUnsavedChanges = false
        
        dismiss()
    }
    
    private func copyExercise() {
        if exercise != nil {
            let exerciseCopy = Exercise(
                name: "Copy of \(exerciseName)",
                notes: exerciseNotes,
                muscleGroup: MuscleGroup(
                    rawValue: selectedMuscleGroup ?? "Other"
                ) ?? .other,
                type: selectedExerciseType
            )
            
            context.insert(exerciseCopy)
            
            do {
                try context.save()
            } catch {
                debugLog("Failed to save workout copy: \(error.localizedDescription)")
            }
        }
        
        hasUnsavedChanges = false
    }
    
    private func deleteExercise() {
        if let exercise = exercise {
            exercise.hide()
            
            do {
                let workouts = (
                    try context.fetch(
                        FetchDescriptor<Workout>()
                    )
                )
                .filter { $0.exercises.contains(where: { $0.exercise?.id == exercise.id }) }
                
                for workout in workouts {
                    workout.exercises.removeAll { $0.exercise?.id == exercise.id }
                }
                
                try context.save()
            } catch {
                debugLog("Error: \(error.localizedDescription)")
            }
        }
    }
}
