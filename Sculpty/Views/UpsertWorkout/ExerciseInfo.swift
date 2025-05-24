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
    @State private var tempoArr: [String]
    
    @FocusState private var isNotesFocused: Bool
    
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
        var initialTempoArr = workoutExercise.tempo.map { String($0) }
        
        while initialTempoArr.count < 4 {
            initialTempoArr.append("0")
        }
        if initialTempoArr.count > 4 {
            initialTempoArr = Array(initialTempoArr.prefix(4))
        }
        
        _restMinutes = State(initialValue: initialRestMinutes)
        _restSeconds = State(initialValue: initialRestSeconds)
        _specNotes = State(initialValue: initialSpecNotes)
        _tempoArr = State(initialValue: initialTempoArr)
    }

    var body: some View {
        ContainerView(title: "Exercise Info", spacing: 20) {
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
            
            if let notes = workoutExercise.exercise?.notes, !notes.isEmpty {
                Text(workoutExercise.exercise!.notes)
                    .bodyText(size: 16)
                    .textColor()
            }
            
            Input(title: "Workout-Specific Notes", text: $specNotes, isFocused: _isNotesFocused, axis: .vertical)
            
            
            Spacer()
                .frame(height: 5)
            
            
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
                            await TempoPopup(tempo: tempoArr.joined(separator: "")).present()
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
                    
                    HStack (spacing: 5) {
                        Picker("Tempo 1", selection: $tempoArr[0]) {
                            tempoPicker()
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: 50)
                        .clipped()
                        
                        Picker("Tempo 2", selection: $tempoArr[1]) {
                            tempoPicker()
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: 50)
                        .clipped()
                        
                        Picker("Tempo 3", selection: $tempoArr[2]) {
                            tempoPicker()
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: 50)
                        .clipped()
                        
                        Picker("Tempo 4", selection: $tempoArr[3]) {
                            tempoPicker()
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: 50)
                        .clipped()
                    }
                    .frame(height: 65)
                    .padding(.bottom)
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
                    isNotesFocused = false
                } label: {
                    Text("Done")
                }
                .disabled(!isNotesFocused)
            }
        }
    }
    
    private func save() {
        workoutExercise.exercise = exercise
        
        let restTotalSeconds = (Double(restMinutes) * 60) + Double(restSeconds)
        workoutExercise.restTime = restTotalSeconds
        
        workoutExercise.specNotes = specNotes
        
        workoutExercise.tempo = tempoArr.joined()
        
        dismiss()
    }
    
    private func tempoPicker() -> some View {
        ForEach(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], id: \.self) { num in
            Text(num)
                .tag(num)
        }
    }
}
 
