//
//  AddMovement.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/12/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct AddExercise: View {
    // Environment Variables
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // View Model
    @StateObject private var viewModel: ExerciseViewModel
    
    @FocusState private var isNameFocused: Bool
    @FocusState private var isNotesFocused: Bool

    init() {
        _viewModel = StateObject(wrappedValue: ExerciseViewModel(exercise: Exercise(name: "", notes: "")))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    // Name
                    TextField("Name", text: $viewModel.name)
                        .textInputAutocapitalization(.words)
                        .focused($isNameFocused)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                        )
                    
                    // Notes
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .focused($isNotesFocused)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                        )
                    
                    
                    Spacer()
                    
                    
                    // Display Selected Muscle Group
                    Text("Selected: \(viewModel.muscleGroup.rawValue.capitalized)")
                        .font(.subheadline)
                        .padding()
                    
                    // Select Muscle Group
                    MuscleGroupMenu()
                    
                    // Display Selected Type
                    Text("Selected: \(viewModel.type.rawValue)")
                        .font(.subheadline)
                        .padding()
                    
                    // Select Type
                    ExerciseTypeMenu()
                    
                    Button("Save Exercise") {
                        viewModel.save(context: context, insert: true)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty
                    )

                }
                .padding()
                .navigationTitle(Text("Add Exercise"))
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
        }
        .environmentObject(viewModel)
    }
}
