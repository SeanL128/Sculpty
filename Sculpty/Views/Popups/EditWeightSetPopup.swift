//
//  EditWeightSetPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/5/25.
//

import SwiftUI

struct EditWeightSetPopup: View {
    @EnvironmentObject private var settings: CloudSettings
    
    var set: ExerciseSet
    @Binding var log: SetLog
    
    private let restTime: Double
    private let restTimer: RestTimer?
    
    @State private var disableType: Bool = false
    
    @State private var updatedSet: ExerciseSet
    
    @State private var weightString: String
    @State private var repsString: String
    
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isWeightFocused: Bool
    
    init (set: ExerciseSet,
          log: Binding<SetLog> = .constant(SetLog(index: -1, set: ExerciseSet(), unit: UnitsManager.weight)),
          restTime: Double = 0,
          timer: RestTimer? = nil,
          disableType: Bool = false) {
        self.set = set
        self._log = log
        
        self.restTime = restTime
        restTimer = timer
        
        self.disableType = disableType
        
        _updatedSet = State(initialValue: set)
        
        let initialWeight = (set.weight ?? 0).formatted()
        let initialReps = "\(set.reps ?? 0)"
        
        _weightString = State(initialValue: initialWeight)
        _repsString = State(initialValue: initialReps)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            // Header
            HStack(alignment: .center, spacing: .spacingL) {
                Spacer()
                
                if log.index > -1 {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            log.unfinish()
                            log.skip()
                        }
                        
                        Popup.dismissLast()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.right.fill")
                            .headingImage()
                    }
                    .textColor()
                    .animatedButton(feedback: .impact(weight: .light))
                }
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        if log.index > -1 {
                            let weight = Double(updatedSet.reps ?? 0) * (updatedSet.weight ?? 0)
                            
                            log.unskip()
                            log.finish(reps: updatedSet.reps ?? 0, weight: weight)
                            
                            if let restTimer = restTimer {
                                var time: Double = 0
                                
                                switch updatedSet.type {
                                case .warmUp:
                                    time = 30
                                case .coolDown:
                                    time = 60
                                default:
                                    time = restTime
                                }
                                
                                restTimer.skip()
                                restTimer.start(duration: time)
                            }
                        }
                    }
                    
                    Popup.dismissLast()
                } label: {
                    Image(systemName: "checkmark")
                        .headingImage()
                }
                .textColor()
                .animatedButton(feedback: .success)
            }
            
            HStack(alignment: .center, spacing: 0) {
                // Reps
                Input(title: "Reps", text: $repsString, isFocused: _isRepsFocused, type: .numberPad)
                    .onChange(of: repsString) {
                        repsString = repsString.filter { "0123456789".contains($0) }
                        
                        if repsString.isEmpty {
                            updatedSet.reps = 0
                        }
                        
                        updatedSet.reps = (repsString as NSString).integerValue
                    }
                    .frame(maxWidth: 130)
                
                Spacer()
                    
                Text("x")
                    .bodyText()
                    .textColor()
                    .frame(maxWidth: 30)
                
                Spacer()
                 
                // Weight
                HStack(alignment: .bottom, spacing: 0) {
                    Input(title: "Weight", text: $weightString, isFocused: _isWeightFocused, type: .decimalPad)
                        .onChange(of: weightString) {
                            weightString = weightString.filteredNumeric()
                            
                            if weightString.isEmpty {
                                updatedSet.weight = 0
                            } else if weightString.hasSuffix(".") {
                                updatedSet.weight = ("\(weightString)0" as NSString).doubleValue
                            } else {
                                updatedSet.weight = (weightString as NSString).doubleValue
                            }
                        }
                        .frame(maxWidth: 85)
                    
                    Button {
                        Popup.show(content: {
                            SmallMenuPopup(title: "Units", options: ["lbs", "kg"], selection: $updatedSet.unit)
                        })
                    } label: {
                        HStack(alignment: .center) {
                            Text(updatedSet.unit)
                                .bodyText(weight: .regular)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .bodyImage(weight: .medium)
                        }
                    }
                    .textColor()
                    .frame(maxWidth: 45)
                    .animatedButton(feedback: .selection)
                }
                .frame(maxWidth: 130)
            }
            
            if !disableType {
                TypedSegmentedControl(
                    selection: $updatedSet.type,
                    options: ExerciseSetType.displayOrder,
                    displayNames: ExerciseSetType.stringDisplayOrder
                )
            }
            
            // RIR
            if settings.showRir && [.main, .dropSet].contains(updatedSet.type) {
                HStack(alignment: .center, spacing: .spacingS) {
                    Text("RIR")
                    
                    TypedSegmentedControl(
                        selection: $updatedSet.rir,
                        options: ["Failure", "0", "1", "2", "3+"],
                        displayNames: ["Failure", "0", "1", "2", "3+"]
                    )
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
    }
}
