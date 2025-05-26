//
//  ExerciseInfo.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/14/25.
//

import SwiftUI
import SwiftData
import MijickPopups

struct ExerciseInfo: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var workout: Workout
    
    @Query private var exercises: [Exercise]
    
    @State private var workoutExercise: WorkoutExercise
    @State private var exercise: Exercise?
    @State private var type: ExerciseType?
    
    @State private var restMinutes: Int
    @State private var restSeconds: Int
    @State private var specNotes: String
    @State private var tempo: String
    
    @FocusState private var isNotesFocused: Bool
    @FocusState private var isTempoFocused: Bool
    
    @AppStorage(UserKeys.showTempo.rawValue) private var showTempo: Bool = false
    
    private var isValid: Bool {
        !workoutExercise.sets.isEmpty && exercise != nil
    }
    
    init(workout: Workout, exercise: Exercise?, workoutExercise: WorkoutExercise) {
        self.workout = workout
        self.exercise = exercise
        self._workoutExercise = State(initialValue: workoutExercise)
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
        ContainerView(title: "Exercise Info", spacing: 20) {
            VStack(alignment: .leading, spacing: 20) {
                NavigationLink(destination: SelectExercise(selectedExercise: $exercise)) {
                    HStack(alignment: .center) {
                        Text(exercise?.name ?? "Select Exercise")
                            .bodyText(size: 20, weight: .bold)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 14, weight: .bold))
                    }
                }
                .textColor()
                .onChange(of: exercise) {
                    if exercise?.type != type {
                        workoutExercise.sets.removeAll()
                    }
                    
                    type = exercise?.type
                }
                
                if let notes = workoutExercise.exercise?.notes, !notes.isEmpty {
                    Text(workoutExercise.exercise!.notes)
                        .bodyText(size: 16)
                        .textColor()
                }
            }
            .padding(.bottom, 20)
            
            
            ForEach(workoutExercise.sets.sorted { $0.index < $1.index }, id: \.id) { set in
                if let index = workoutExercise.sets.firstIndex(of: set) {
                    HStack(alignment: .center) {
                        Button {
                            let type = type ?? .weight
                            
                            Task {
                                switch type {
                                case .weight:
                                    await EditWeightSetPopup(set: set).present()
                                case .distance:
                                    await EditDistanceSetPopup(set: set).present()
                                }
                            }
                        } label: {
                            SetView(set: set)
                        }
                        .textColor()
                        
                        Spacer()
                        
                        Button {
                            var updatedSets = workoutExercise.sets
                            updatedSets.remove(at: index)
                            workoutExercise.sets = updatedSets
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
                var updatedSets = workoutExercise.sets
                
                let nextIndex = updatedSets.isEmpty ? 0 : (updatedSets.map { $0.index }.max() ?? -1) + 1
                
                let newSet = ExerciseSet(index: nextIndex, type: type ?? .weight)
                updatedSets.append(newSet)
                
                workoutExercise.sets = updatedSets
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "plus")
                        .font(Font.system(size: 16))
                    
                    Text("Add Set")
                        .bodyText(size: 16)
                }
            }
            .textColor()
            
            
            Spacer()
                .frame(height: 5)
            
            
            VStack(alignment: .leading) {
                Text("Rest Time")
                    .bodyText(size: 12)
                    .textColor()
                
                HStack(spacing: 20) {
                    // Minutes Picker
                    Picker("Minutes", selection: $restMinutes) {
                        ForEach(Array(0...59), id: \.self) { minute in
                            Text("\(minute) min")
                                .tag(minute)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: 150)
                    .clipped()
                    
                    // Seconds Picker
                    Picker("Seconds", selection: $restSeconds) {
                        ForEach([0, 15, 30, 45], id: \.self) { second in
                            Text("\(second) sec")
                                .tag(second)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: 150)
                    .clipped()
                }
                .padding(.top)
                .padding(.horizontal)
                .frame(height: 65)
            }
            
            if showTempo {
                VStack(alignment: .leading) {
                    Button {
                        Task {
                            await TempoPopup(tempo: tempo).present()
                        }
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
                    
                    HStack(alignment: .bottom) {
                        TextField("", text: $tempo, prompt: Text("0000"))
                            .keyboardType(.numberPad)
                            .focused($isTempoFocused)
                            .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isTempoFocused }, set: { isTempoFocused = $0 }), text: $tempo))
                            .onChange(of: tempo) {
                                if tempo.count > 4 {
                                    tempo = String(tempo.prefix(4))
                                }
                            }
                    }
                    .frame(maxWidth: 50)
                }
            }
            
            
            Spacer()
                .frame(height: 5)
            
            
            Input(title: "Workout-Specific Notes", text: $specNotes, isFocused: _isNotesFocused, axis: .vertical)
            
            
            Spacer()
                .frame(height: 5)
            
            
            Button {
                save()
            } label: {
                Text("Save")
                    .bodyText(size: 18)
            }
            .textColor()
            .disabled(!isValid)
        }
        .toolbar {
            ToolbarItemGroup (placement: .keyboard) {
                Spacer()
                
                KeyboardDoneButton(focusStates: [_isNotesFocused, _isTempoFocused])
            }
        }
    }
    
    private func save() {
        workoutExercise.exercise = exercise
        
        let restTotalSeconds = (Double(restMinutes) * 60) + Double(restSeconds)
        workoutExercise.restTime = restTotalSeconds
        
        workoutExercise.specNotes = specNotes
        
        while tempo.count < 4 {
            tempo.append("0")
        }
        workoutExercise.tempo = tempo
        
        dismiss()
    }
}
 
