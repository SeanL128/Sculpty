//
//  EditWeightSetPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/5/25.
//

import SwiftUI
import MijickTimer
import BRHSegmentedControl

struct EditWeightSetPopup: View {
    @EnvironmentObject private var settings: CloudSettings
    
    var set: ExerciseSet
    @Binding var log: SetLog
    
    private let restTime: Double
    private let restTimer: MTimer?
    
    private let setTimer: MTimer
    @State private var setTime: MTime = .init()
    @State private var setTimerStatus: MTimerStatus = .notStarted
    
    @State private var disableType: Bool = false
    
    @State private var selectedTypeIndex: Int = 1
    
    @State private var selectedRirIndex: Int = 1
    private let rirLabels: [String] = ["Failure", "0", "1", "2", "3+"]
    
    @State private var updatedSet: ExerciseSet
    
    @State private var weightString: String
    @State private var repsString: String
    
    @FocusState private var isRepsFocused: Bool
    @FocusState private var isWeightFocused: Bool
    
    init (set: ExerciseSet,
          log: Binding<SetLog> = .constant(SetLog(index: -1, set: ExerciseSet(), unit: UnitsManager.weight)),
          restTime: Double = 0,
          timer: MTimer? = nil,
          disableType: Bool = false) {
        self.set = set
        self._log = log
        
        self.restTime = restTime
        restTimer = timer
        
        setTimer = MTimer(MTimerID(rawValue: "Set Timer \(log.id)"))
        
        self.disableType = disableType
        
        self.selectedTypeIndex = ExerciseSetType.displayOrder.firstIndex(of: set.type) ?? 1
        
        self.selectedRirIndex = rirLabels.firstIndex(of: set.rir ?? "0") ?? 1
        
        _updatedSet = State(initialValue: set)
        
        let initialWeight = (set.weight ?? 0).formatted()
        let initialReps = "\(set.reps ?? 0)"
        
        _weightString = State(initialValue: initialWeight)
        _repsString = State(initialValue: initialReps)
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Spacer()
                
                if log.index > -1 {
                    Button {
                        log.unfinish()
                        log.skip()
                        
                        Popup.dismissLast()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.right.fill")
                            .padding(.horizontal, 3)
                            .font(Font.system(size: 16))
                    }
                    .textColor()
                }
                
                Button {
                    if log.index > -1 {
                        let weight = Double(updatedSet.reps ?? 0) * (updatedSet.weight ?? 0)
                        
                        log.unskip()
                        log.finish(reps: updatedSet.reps ?? 0, weight: weight)
                        
                        if let restTimer = restTimer {
                            var time: Double = 0
                            
                            switch (updatedSet.type) {
                            case (.warmUp):
                                time = 30
                            case (.coolDown):
                                time = 60
                            default:
                                time = restTime
                            }
                            
                            try? restTimer.skip()
                            try? restTimer.start(from: time, to: .zero)
                        }
                    }
                    
                    Popup.dismissLast()
                } label: {
                    Image(systemName: "checkmark")
                        .padding(.horizontal, 3)
                        .font(Font.system(size: 16))
                }
                .textColor()
            }
            .padding(.top, 25)
            .padding(.bottom, 1)
            
            HStack {
                // Reps
                Input(title: "Reps", text: $repsString, isFocused: _isRepsFocused, type: .numberPad)
                    .onChange(of: repsString) {
                        repsString = repsString.filter { "0123456789".contains($0) }
                        
                        if repsString.isEmpty {
                            updatedSet.reps = 0
                        }
                        
                        updatedSet.reps = (repsString as NSString).integerValue
                    }
                    .frame(maxWidth: 115)
                
                Spacer()
                    
                Text("x")
                    .bodyText(size: 20)
                    .textColor()
                    .frame(maxWidth: 45)
                
                Spacer()
                 
                // Weight
                HStack {
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
                        .frame(maxWidth: 145)
                    
                    Button {
                        Popup.show(content: {
                            SmallMenuPopup(title: "Units", options: ["lbs", "kg"], selection: $updatedSet.unit)
                        })
                    } label: {
                        HStack(alignment: .center) {
                            Text(updatedSet.unit)
                                .bodyText(size: 18, weight: .bold)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(Font.system(size: 12, weight: .bold))
                        }
                    }
                    .textColor()
                    .frame(maxWidth: 55)
                }
                .frame(maxWidth: 230)
            }
            .padding(.bottom, 10)
            
            if !disableType {
                BRHSegmentedControl(
                    selectedIndex: $selectedTypeIndex,
                    labels: ExerciseSetType.stringDisplayOrder,
                    builder: { _, label in
                        Text(label)
                            .bodyText(size: 12, weight: .bold)
                            .multilineTextAlignment(.center)
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
                .onChange(of: selectedTypeIndex) {
                    updatedSet.type = ExerciseSetType.displayOrder[selectedTypeIndex]
                }
            }
            
            // RIR
            if settings.showRir && [.main, .dropSet].contains(updatedSet.type) {
                HStack {
                    Text("RIR")
                        .padding(.horizontal, 5)
                    
                    BRHSegmentedControl(
                        selectedIndex: $selectedRirIndex,
                        labels: rirLabels,
                        builder: { _, label in
                            Text(label)
                                .bodyText(size: 12, weight: .bold)
                                .multilineTextAlignment(.center)
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
                    .onChange(of: selectedRirIndex) {
                        updatedSet.rir = rirLabels[selectedRirIndex]
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding(.top, -30)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                KeyboardDoneButton(focusStates: [_isRepsFocused, _isWeightFocused])
            }
        }
    }
    
    func startTimer() throws {
        try setTimer
            .publish(every: 1, currentTime: $setTime)
            .bindTimerStatus(timerStatus: $setTimerStatus)
            .start()
    }
}
