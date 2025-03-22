//
//  EditSetPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/5/25.
//

import SwiftUI
import Neumorphic
import MijickPopups

struct EditSetPopup: BottomPopup {
    @Binding var set: ExerciseSet
    @Binding var log: SetLog
    @Binding var timeRemaining: Double
    
    private var restTime: Double
    
    @State private var weightString: String
    @State private var repsString: String
    
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isWeightFocused: Bool
    
    @AppStorage(UserKeys.showRir.rawValue) private var showRir: Bool = false
    
    init (set: Binding<ExerciseSet>, log: Binding<SetLog> = .constant(SetLog(index: -1, set: ExerciseSet())), timeRemaining: Binding<Double> = .constant(0), restTime: Double = 0) {
        self._set = set
        self._log = log
        self._timeRemaining = timeRemaining
        
        self.restTime = restTime
        
        let initialWeight = set.wrappedValue.weight.formatted()
        let initialReps = "\(set.wrappedValue.reps)"
        
        _weightString = State(initialValue: initialWeight)
        _repsString = State(initialValue: initialReps)
    }
    
    var body: some View {
        VStack {
            // Header
            if log.index != -1 {
                HStack {
                    Spacer()
                    
                    Button {
                        log.unfinish()
                        log.skip()
                        
                        Task {
                            await dismissLastPopup()
                        }
                    } label: {
                        Image(systemName: "arrowshape.turn.up.right.fill")
                    }
                    .padding(3)
                    
                    Button {
                        let weight = set.measurement == "x" ? Double(set.reps) * set.weight : 0
                        
                        log.unskip()
                        log.finish(reps: set.reps, weight: weight, measurement: set.measurement)
                        
                        Task {
                            await dismissLastPopup()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .padding(3)
                }
                .padding(.top, 30)
                .padding(.bottom, -50)
            }
            
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
                    
                    Spacer()
                }
                .frame(maxWidth: 175)
                
                Spacer()
                
                // Measurement
                Picker("Measurement", selection: $set.measurement) {
                    ForEach(["x", "min", "sec"], id: \.self) { measurement in
                        Text("\(measurement)")
                            .tag(measurement)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: 75, maxHeight: 125)
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
                    .frame(maxHeight: 100)
                    .clipped()
                    .padding(.leading, 5)
                }
                .frame(maxWidth: 175)
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
            if showRir && [.main, .dropSet].contains(set.type) {
                HStack {
                    Text("RIR")
                        .padding(.horizontal, 5)
                    
                    Picker("RIR", selection: $set.rir) {
                        ForEach(["Failure", "0", "1", "2", "3+"], id: \.self) { rir in
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
    
    private func updateTimeRemaining() async {
        
    }
    
    func configurePopup(config: BottomPopupConfig) -> BottomPopupConfig {
        config
            .heightMode(.auto)
            .dragDetents([.fraction(1.2)])
            .enableDragGesture(false)
            .backgroundColor(ColorManager.background)
    }
}
