//
//  EditWeightSetPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/5/25.
//

import SwiftUI
import MijickPopups
import MijickTimer

struct EditWeightSetPopup: CenterPopup {
    @EnvironmentObject private var settings: CloudSettings
    
    var set: ExerciseSet
    @Binding var log: SetLog
    
    private let restTime: Double
    private let restTimer: MTimer?
    
    private let setTimer: MTimer
    @State private var setTime: MTime = .init()
    @State private var setTimerStatus: MTimerStatus = .notStarted
    
    @State private var disableType: Bool = false
    
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
                        
                        Task {
                            await dismissLastPopup()
                        }
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
                    
                    Task {
                        await dismissLastPopup()
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .padding(.horizontal, 3)
                        .font(Font.system(size: 16))
                }
                .textColor()
            }
            .padding(.top, 30)
            
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
                        Task {
                            await SmallMenuPopup(title: "Units", options: ["lbs", "kg"], selection: $updatedSet.unit).present()
                        }
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
                Picker("Type", selection: $updatedSet.type) {
                    ForEach(ExerciseSetType.displayOrder, id: \.id) { type in
                        Text("\(type.rawValue)")
                            .bodyText(size: 16)
                            .textColor()
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .clipped()
            }
            
            // RIR
            if settings.showRir && [.main, .dropSet].contains(updatedSet.type) {
                HStack {
                    Text("RIR")
                        .padding(.horizontal, 5)
                    
                    Picker("RIR", selection: $updatedSet.rir) {
                        ForEach(["Failure", "0", "1", "2", "3+"], id: \.self) { rir in
                            Text("\(rir)")
                                .bodyText(size: 16)
                                .textColor()
                                .tag(rir)
                        }
                    }
                    .pickerStyle(.segmented)
                    .clipped()
                }
                .padding(.top, 10)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top, -10)
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
    
    func configurePopup(config: CenterPopupConfig) -> CenterPopupConfig {
        config
            .backgroundColor(ColorManager.background)
    }
}
