//
//  UpsertExercise.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData
import BRHSegmentedControl

struct UpsertExercise: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State var exercise: Exercise
    
    @Binding var selectedExercise: Exercise?
    
    @State var new: Bool
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool
    
    @State private var selectedMuscleGroup: String?
    @State private var selectedExerciseType: Int = 0
    
    private var isValid: Bool {
        !exercise.name.trimmingCharacters(in: .whitespaces).isEmpty && selectedMuscleGroup != nil
    }
    
    init(exercise: Exercise = Exercise(), selectedExercise: Binding<Exercise?> = .constant(nil)) {
        self.exercise = exercise
        
        new = (exercise.name == "")
        
        self._selectedExercise = selectedExercise
    }
    
    var body: some View {
        ContainerView(title: "\(new ? "Add" : "Edit") Exercise", spacing: 20) {
            Input(title: "Name", text: $exercise.name, isFocused: _isNameFocused, autoCapitalization: .words)
            
            Input(title: "Notes", text: $exercise.notes, isFocused: _isNotesFocused, axis: .vertical)
            
            
            Spacer()
                .frame(height: 5)
            
            
            VStack(alignment: .leading) {
                Text("Muscle Group")
                    .bodyText(size: 12)
                    .textColor()
                
                Button {
                    Task {
                        await MenuPopup(title: "Muscle Group", options: MuscleGroup.stringDisplayOrder, selection: $selectedMuscleGroup).present()
                    }
                } label: {
                    HStack(alignment: .center) {
                        Text(selectedMuscleGroup ?? "Select")
                            .bodyText(size: 16)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 10))
                    }
                }
                .textColor()
                .onChange(of: selectedMuscleGroup) {
                    exercise.muscleGroup = MuscleGroup(rawValue: selectedMuscleGroup ?? "Other")
                }
            }
            
            VStack(alignment: .leading) {
                Text("Tracking Type")
                    .bodyText(size: 12)
                    .textColor()
                
                BRHSegmentedControl(
                    selectedIndex: $selectedExerciseType,
                    labels: ExerciseType.stringDisplayOrder,
                    builder: { _, label in
                        Text(label)
                            .bodyText(size: 16)
                    },
                    styler: { state in
                        switch state {
                        case .none:
                            return ColorManager.secondary
                        case .touched:
                            return ColorManager.secondary.opacity(0.7)
                        case .selected:
                            return ColorManager.text
                        }
                    }
                )
                .onChange(of: selectedExerciseType) {
                    exercise.type = ExerciseType.displayOrder[selectedExerciseType]
                }
            }
            
            
            Spacer()
                .frame(height: 5)
            
            
            Button {
                save()
            } label: {
                Text("Save")
                    .bodyText(size: 18)
            }
            .disabled(!isValid)
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
        .onAppear() {
            if !new {
                selectedMuscleGroup = exercise.muscleGroup?.rawValue ?? "Other"
                selectedExerciseType = ExerciseType.stringDisplayOrder.firstIndex(of: exercise.type.rawValue) ?? 0
            }
        }
    }
    
    private func save() {
        if new {
            context.insert(exercise)
        }
        
        try? context.save()
        
        selectedExercise = exercise
        
        dismiss()
    }
}
