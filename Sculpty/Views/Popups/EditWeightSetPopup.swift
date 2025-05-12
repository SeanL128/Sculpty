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
    
    @AppStorage(UserKeys.showRir.rawValue) private var showRir: Bool = false
    @AppStorage(UserKeys.showSetTimer.rawValue) private var showSetTimer: Bool = false
    
    init (set: ExerciseSet,
          log: Binding<SetLog> = .constant(SetLog(index: -1, set: ExerciseSet())),
          restTime: Double = 0,
          timer: MTimer? = nil,
          disableType: Bool = false) {
        self.set = set
        self._log = log
        
        self.restTime = restTime
        self.restTimer = timer
        
        self.setTimer = MTimer(MTimerID(rawValue: "Set Timer \(log.id)"))
        
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
                    }
                    .padding(3)
                }
                
                Button {
                    if log.index > -1 {
                        let weight = updatedSet.measurement == "x" ? Double(updatedSet.reps ?? 0) * (updatedSet.weight ?? 0) : 0
                        
                        log.unskip()
                        log.finish(reps: updatedSet.reps ?? 0, weight: weight, measurement: updatedSet.measurement ?? "x")
                        
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
                }
                .padding(3)
            }
            .padding(.top, 30)
            .padding(.bottom, -20)
            
            HStack {
                // Reps
                HStack {
                    TextField("Reps", text: $repsString)
                        .keyboardType(.numberPad)
                        .focused($isRepsFocused)
                        .onChange(of: repsString) {
                            repsString = repsString.filter { "0123456789".contains($0) }
                            
                            if repsString.isEmpty {
                                updatedSet.reps = 0
                            }
                            
                            updatedSet.reps = (repsString as NSString).integerValue
                        }
                        .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isRepsFocused }, set: { isRepsFocused = $0 })))
                        .frame(maxWidth: 125)
                    
                    Spacer()
                }
                
                Spacer()
                
                // Measurement
                Picker("Measurement", selection: $updatedSet.measurement) {
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
                                updatedSet.weight = 0
                            } else if weightString.hasSuffix(".") {
                                updatedSet.weight = ("\(weightString)0" as NSString).doubleValue
                            } else {
                                updatedSet.weight = (weightString as NSString).doubleValue
                            }
                        }
                        .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isWeightFocused }, set: { isWeightFocused = $0 })))
                        .frame(maxWidth: 125)
                    
                    Picker("Unit", selection: $updatedSet.unit) {
                        Text("lbs")
                            .bodyText()
                            .textColor()
                            .tag("lbs")
                        
                        Text("kg")
                            .bodyText()
                            .textColor()
                            .tag("kg")
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: 65, maxHeight: 100)
                    .clipped()
                    .padding(.leading, 5)
                }
                .frame(maxWidth: 190)
            }
            .padding(.bottom, 10)
            
            if !disableType {
                Picker("Type", selection: $updatedSet.type) {
                    ForEach(ExerciseSetType.displayOrder, id: \.self) { type in
                        Text("\(type.rawValue)")
                            .bodyText()
                            .textColor()
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .clipped()
            }
            
            // RIR
            if showRir && [.main, .dropSet].contains(updatedSet.type) {
                HStack {
                    Text("RIR")
                        .padding(.horizontal, 5)
                    
                    Picker("RIR", selection: $updatedSet.rir) {
                        ForEach(["Failure", "0", "1", "2", "3+"], id: \.self) { rir in
                            Text("\(rir)")
                                .bodyText()
                                .textColor()
                                .tag(rir)
                        }
                    }
                    .pickerStyle(.segmented)
                    .clipped()
                }
                .padding(.top, 10)
            }
            
            if log.index != -1 && showSetTimer && ["min", "sec"].contains(set.measurement) {
                HStack {
                    Text("\(setTime.toString())")
                    
                    Spacer()
                    
                    Button {
                        if setTimerStatus == .notStarted {
                            try? startTimer()
                        } else if setTimerStatus == .paused {
                            try? setTimer.resume()
                        } else {
                            setTimer.pause()
                        }
                    } label: {
                        Image(systemName: (setTimerStatus == .notStarted || setTimerStatus == .paused) ? "play.fill" : "pause.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.trailing, 5)
                    
                    Button {
                        setTimer.cancel()
                    } label: {
                        Image(systemName: "stop.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.leading, 5)
                    .disabled(setTimer.timerStatus != .running && setTimer.timerStatus != .paused)
                }
                .font(.title2)
                .padding(.top, 10)
                .padding(.horizontal, 30)
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
