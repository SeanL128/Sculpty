//
//  EditDistanceSetPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/24/25.
//

import SwiftUI
import MijickPopups
import MijickTimer

struct EditDistanceSetPopup: CenterPopup {
    var set: ExerciseSet
    @Binding var log: SetLog
    
    private let restTime: Double
    private let restTimer: MTimer?

    private let setTimer: MTimer
    @State private var setTime: MTime = .init()
    @State private var setTimerStatus: MTimerStatus = .notStarted
    
    @State private var disableType: Bool = false
    
    @State private var updatedSet: ExerciseSet
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    @State private var distanceString: String
    
    @FocusState private var isDistanceFocused: Bool
    
    @AppStorage(UserKeys.showSetTimer.rawValue) private var showSetTimer: Bool = false
    
    init (set: ExerciseSet,
          log: Binding<SetLog> = .constant(SetLog(index: -1, set: ExerciseSet())),
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
        
        let total = Int(set.time ?? 0)
        hours = total / 3600
        minutes = (total % 3600) / 60
        seconds = total % 60
        
        distanceString = (set.distance ?? 0).formatted()
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
                }
                
                Button {
                    if log.index > -1 {
                        log.unskip()
                        log.finish(time: (updatedSet.time ?? 0), distance: (updatedSet.distance ?? 0))
                        
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
            }
            .padding(.top, 30)
            .padding(.bottom, -20)
            
            HStack {
                HStack {
                    Picker("Hours", selection: $hours) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text("\(hour)h").tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 75, height: 100)
                    .clipped()

                    Picker("Minutes", selection: $minutes) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text("\(minute)m").tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 75, height: 100)
                    .clipped()

                    Picker("Seconds", selection: $seconds) {
                        ForEach(0..<60, id: \.self) { second in
                            Text("\(second)s").tag(second)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 75, height: 100)
                    .clipped()
                }
                .onChange(of: hours) { updateTime() }
                .onChange(of: minutes) { updateTime() }
                .onChange(of: seconds) { updateTime() }
                
                HStack {
                    Input(title: "Distance", text: $distanceString, isFocused: _isDistanceFocused, type: .decimalPad)
                        .onChange(of: distanceString) {
                            distanceString = distanceString.filteredNumeric()
                             
                            if distanceString.isEmpty {
                                updatedSet.distance = 0
                            } else if distanceString.hasSuffix(".") {
                                updatedSet.distance = ("\(distanceString)0" as NSString).doubleValue
                            } else {
                                updatedSet.distance = (distanceString as NSString).doubleValue
                            }
                        }
                        .frame(maxWidth: 125)
                    
                    Picker("Unit", selection: $updatedSet.unit) {
                        Text("mi")
                            .bodyText(size: 16)
                            .textColor()
                            .tag("mi")
                        
                        Text("km")
                            .bodyText(size: 16)
                            .textColor()
                            .tag("km")
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
                            .bodyText(size: 16)
                            .textColor()
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .clipped()
            }
            
            if log.index != -1 && showSetTimer {
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
                            .padding(.horizontal, 3)
                            .font(Font.system(size: 16))
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        setTimer.cancel()
                    } label: {
                        Image(systemName: "stop.fill")
                            .padding(.horizontal, 3)
                            .font(Font.system(size: 16))
                    }
                    .buttonStyle(.borderedProminent)
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
                    isDistanceFocused = false
                } label: {
                    Text("Done")
                }
                .disabled(!isDistanceFocused)
            }
        }
    }
    
    func updateTime() {
        updatedSet.time = Double((hours * 3600) + (minutes * 60) + seconds)
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
