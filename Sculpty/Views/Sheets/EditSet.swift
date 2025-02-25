//
//  EditSet.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/16/25.
//

import SwiftUI
import Neumorphic

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
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    HStack {
                        // Reps
                        HStack {
                            TextField("Reps", text: $repsString)
                                .keyboardType(.numberPad)
                                .focused($isRepsFocused)
                                .onChange(of: repsString) {
                                    repsString = repsString.filter { "0123456789".contains($0) }
                                    
                                    if repsString.isEmpty {
                                        set.reps = 0
                                    }
                                    
                                    set.reps = (repsString as NSString).integerValue
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                        .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                                )
                            
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
                                .focused($isWeightFocused)
                                .onChange(of: weightString) {
                                    weightString = weightString.filteredNumeric()
                                    
                                    if weightString.isEmpty {
                                        set.weight = 0
                                    } else if weightString.hasSuffix(".") {
                                        set.weight = ("\(weightString)0" as NSString).doubleValue
                                    } else {
                                        set.weight = (weightString as NSString).doubleValue
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                        .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                                )
                            
                            Picker("Unit", selection: $set.unit) {
                                Text("lbs").tag("lbs")
                                
                                Text("kg").tag("kg")
                            }
                            .pickerStyle(.wheel)
                            .clipped()
                            .padding(.leading, 5)
                        }
                        .frame(maxWidth: 125)
                    }
                    
                    Picker("Type", selection: $set.type) {
                        ForEach(ExerciseSetType.displayOrder, id: \.self) { type in
                            Text("\(type.rawValue)")
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .clipped()
                    
                    // RIR
                    if [.main, .dropSet].contains(set.type) {
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
                        .disabled(!(isRepsFocused || isWeightFocused))
                    }
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    EditSet(set: .constant(ExerciseSet()))
}
