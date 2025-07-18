//
//  ExerciseInfo.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/14/25.
//

import SwiftUI
import SwiftData

struct ExerciseInfo: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var settings: CloudSettings
    
    private var workout: Workout
    
    @State private var workoutExercise: WorkoutExercise
    @State private var exercise: Exercise?
    @State private var type: ExerciseType?
    private var sortedSets: [ExerciseSet] { workoutExercise.sets.sorted { $0.index < $1.index } }
    
    @State private var restMinutes: Int
    @State private var restSeconds: Int
    @State private var specNotes: String
    @State private var tempo: String
    
    @FocusState private var isNotesFocused: Bool
    @FocusState private var isTempoFocused: Bool
    
    @State private var editing: Bool = false
    
    private var onChangesMade: (() -> Void)?
    
    private var isValid: Bool {
        !workoutExercise.sets.isEmpty && exercise != nil
    }
    
    init(workout: Workout, exercise: Exercise?, workoutExercise: WorkoutExercise, onChangesMade: (() -> Void)? = nil) {
        self.workout = workout
        self.exercise = exercise
        self._workoutExercise = State(initialValue: workoutExercise)
        self.onChangesMade = onChangesMade
        type = exercise?.type
        
        let restTotalSeconds = Double(workoutExercise.restTime)
        let initialRestMinutes = Int(restTotalSeconds / 60)
        let initialRestSeconds = Int(restTotalSeconds - Double(initialRestMinutes * 60))
        let initialSpecNotes = workoutExercise.specNotes
        var initialTempo = workoutExercise.tempo
        
        while initialTempo.count < 4 {
            initialTempo.append("0")
        }
        if initialTempo.count > 4 {
            initialTempo = String(initialTempo.prefix(4))
        }
        
        _restMinutes = State(initialValue: initialRestMinutes)
        _restSeconds = State(initialValue: initialRestSeconds)
        _specNotes = State(initialValue: initialSpecNotes)
        _tempo = State(initialValue: initialTempo)
    }

    var body: some View {
        ContainerView(title: "Exercise Info", spacing: 20, onDismiss: { save(false) }) {
            VStack(alignment: .leading, spacing: 20) {
                NavigationLink {
                    SelectExercise(selectedExercise: $exercise)
                } label: {
                    HStack(alignment: .center) {
                        Text(exercise?.name ?? "Select Exercise")
                            .bodyText(size: 20, weight: .bold)
                            .animation(.easeInOut(duration: 0.3), value: exercise?.name)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 14, weight: .bold))
                    }
                }
                .textColor()
                .animatedButton(scale: 0.98)
                .onChange(of: exercise) {
                    if exercise?.type != type {
                        workoutExercise.sets.removeAll()
                    }
                    
                    type = exercise?.type
                }
                
                if let notes = workoutExercise.exercise?.notes, !notes.isEmpty {
                    Text(notes)
                        .bodyText(size: 16)
                        .textColor()
                }
            }
            
            if sortedSets.count > 0 {
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
                    .animatedButton()
                    .animation(.easeInOut(duration: 0.3), value: editing)
                }
            }
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(workoutExercise.sets.sorted { $0.index < $1.index }, id: \.id) { set in
                    EditSetRow(
                        set: set,
                        sortedSets: sortedSets,
                        editing: editing,
                        type: type,
                        workoutExercise: $workoutExercise
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    ))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: sortedSets.count)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: editing)
            
            Button {
                let nextIndex = workoutExercise.sets.isEmpty ? 0 : (workoutExercise.sets.map { $0.index }.max() ?? -1) + 1 // swiftlint:disable:this line_length
                
                let newSet = ExerciseSet(index: nextIndex, type: type ?? .weight)
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    var updatedSets = workoutExercise.sets
                    updatedSets.append(newSet)
                    workoutExercise.sets = updatedSets
                }
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "plus")
                        .font(Font.system(size: 12, weight: .bold))
                    
                    Text("Add Set")
                        .bodyText(size: 16, weight: .bold)
                }
            }
            .textColor()
            .animatedButton(scale: 0.98, feedback: .impact(weight: .light))
            
            Spacer()
                .frame(height: 5)
            
            Button {
                Popup.show(content: {
                    DurationSelectionPopup(title: "Rest Time", minutes: $restMinutes, seconds: $restSeconds)
                })
            } label: {
                HStack(alignment: .center) {
                    HStack(alignment: .center, spacing: 0) {
                        Text("Rest Time:")
                            .bodyText(size: 18, weight: .bold)
                        
                        Text(" \(restMinutes)min \(restSeconds)sec")
                            .bodyText(size: 18)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: restMinutes)
                            .animation(.easeInOut(duration: 0.3), value: restSeconds)
                    }
                    
                    Image(systemName: "chevron.right")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12, weight: .bold))
                }
            }
            .textColor()
            .animatedButton(scale: 0.98)
            
            Spacer()
                .frame(height: 5)
            
            if settings.showTempo {
                VStack(alignment: .leading) {
                    Button {
                        Popup.show(content: {
                            TempoPopup(tempo: tempo)
                        })
                    } label: {
                        HStack {
                            Text("Tempo")
                                .bodyText(size: 12)
                            
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 6))
                        }
                    }
                    .textColor()
                    .animatedButton(scale: 0.98)
                    
                    HStack(alignment: .bottom) {
                        TextField("", text: $tempo, prompt: Text("0000"))
                            .keyboardType(.numberPad)
                            .focused($isTempoFocused)
                            .textFieldStyle(
                                UnderlinedTextFieldStyle(
                                    isFocused: Binding<Bool>(
                                        get: { isTempoFocused },
                                        set: { isTempoFocused = $0 }
                                    ),
                                    text: $tempo
                                )
                            )
                            .onChange(of: tempo) {
                                if tempo.count > 4 {
                                    tempo = String(tempo.prefix(4))
                                }
                            }
                    }
                    .frame(maxWidth: 50)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
            
            Spacer()
                .frame(height: 5)
            
            Input(title: "Workout-Specific Notes", text: $specNotes, isFocused: _isNotesFocused, axis: .vertical)
            
            Spacer()
                .frame(height: 5)
            
            SaveButton(save: save, isValid: isValid, size: 20)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
    }
    
    private func save() { save(true) }
    
    private func save(_ dismissAfter: Bool = true) {
        if !sortedSets.isEmpty {
            workoutExercise.exercise = exercise
            
            let restTotalSeconds = (Double(restMinutes) * 60) + Double(restSeconds)
            workoutExercise.restTime = restTotalSeconds
            
            workoutExercise.specNotes = specNotes
            
            while tempo.count < 4 {
                tempo.append("0")
            }
            workoutExercise.tempo = tempo
            
            onChangesMade?()
        }
        
        if dismissAfter {
            dismiss()
        }
    }
}
