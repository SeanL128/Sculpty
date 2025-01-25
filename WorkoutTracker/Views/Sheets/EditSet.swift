//
//  EditSet.swift
//  WorkoutTracker
//
//  Created by Sean Lindsay on 1/16/25.
//

import SwiftUI

struct EditSet: View {
    @Binding var set: ExerciseSet
    @Binding var exerciseStatus: Int
    @Binding var isPresented: Bool
    
    @State private var weight: Int = 40
    @State private var weightDecimal: Int = 0
    
    @State private var weightString: String
    @State private var repsString: String
    
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isWeightFocused: Bool
    var isAnyFieldFocused: Bool {
        isRepsFocused || isWeightFocused
    }
    
    init (set: Binding<ExerciseSet>, exerciseStatus: Binding<Int> = .constant(0), isPresented: Binding<Bool> = .constant(false)) {
        self._set = set
        self._exerciseStatus = exerciseStatus
        self._isPresented = isPresented
        
        let initialWeight = set.wrappedValue.weight.formatted()
        let initialReps = "\(set.wrappedValue.reps)"
        
        _weightString = State(initialValue: initialWeight)
        _repsString = State(initialValue: initialReps)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    // Reps
                    HStack {
                        TextField("Reps", text: $repsString)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($isRepsFocused)
                            .onChange(of: repsString) {
                                repsString = repsString.filter { "0123456789".contains($0) }
                                
                                if repsString.isEmpty {
                                    set.reps = 0
                                }
                                
                                set.reps = (repsString as NSString).integerValue
                            }
                        
                        Text("reps")
                            .padding(.leading, 5)
                    }
                    .frame(maxWidth: 125)
                    
                    Spacer()
                    
                    // Measurement
                    Picker("Measurement", selection: $set.measurement) {
                        ForEach(["x", "min", "sec"], id: \.self) { measurement in
                            Text("\(measurement)")
                                .tag(measurement)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: 75)
                    .clipped()
                    
                    Spacer()
                     
                    // Weight
                    HStack {
                        TextField("Weight", text: $weightString)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .focused($isWeightFocused)
                            .onChange(of: weightString) {
                                let filtered = weightString.filter { "0123456789.".contains($0) }
                                
                                let components = filtered.split(separator: ".")
                                if components.count > 2 {
                                    weightString = components[0] + "." + components[1]
                                } else {
                                    weightString = filtered
                                }
                                
                                if weightString.isEmpty {
                                    set.weight = 0
                                } else if weightString.hasSuffix(".") {
                                    set.weight = ("\(weightString)0" as NSString).doubleValue
                                } else {
                                    set.weight = (weightString as NSString).doubleValue
                                }
                            }
                        
                        Text("lbs")
                            .padding(.leading, 5)
                    }
                    .frame(maxWidth: 125)
                }
                
                Picker("Type", selection: $set.type) {
                    ForEach(["Warm Up", "Main", "Drop Set", "Cool Down"], id: \.self) { type in
                        Text("\(type)")
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .clipped()
                
                // RIR
                HStack {
                    Text("RIR")
                        .padding(.horizontal, 5)
                    
                    Picker("RIR", selection: $set.rir) {
                        ForEach(["Failure", "0", "1", "2"], id: \.self) { rir in
                            Text("\(rir)")
                                .tag(rir)
                        }
                    }
                    .pickerStyle(.segmented)
                    .clipped()
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .padding(.top, -10)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if exerciseStatus >= 1 {
                        Button {
                            exerciseStatus = 4
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                        
                        Button {
                            exerciseStatus = 3
                            isPresented = false
                        } label: {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                        }
                        
                        Button {
                            exerciseStatus = 2
                            isPresented = false
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button {
                        isRepsFocused = false
                        isWeightFocused = false
                    } label: {
                        Text("Done")
                    }
                    .disabled(!isAnyFieldFocused)
                }
            }
            
            Spacer()
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    EditSet(set: .constant(ExerciseSet()))
}
