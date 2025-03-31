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
    @Binding var set: DistanceSet
    @Binding var log: SetLog
    
    private let restTime: Double
    private let restTimer: MTimer?
    
    private let setTimer: MTimer
    @State private var setTime: MTime = .init()
    @State private var setTimerStatus: MTimerStatus = .notStarted
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    @State private var distanceString: String
    
    @FocusState private var isDistanceFocused: Bool
    
    @AppStorage(UserKeys.showSetTimer.rawValue) private var showSetTimer: Bool = false
    
    init (set: Binding<DistanceSet>, log: Binding<SetLog> = .constant(SetLog(index: -1, set: ExerciseSet())), restTime: Double = 0, timer: MTimer? = nil) {
        self._set = set
        self._log = log
        
        self.restTime = restTime
        self.restTimer = timer
        
        self.setTimer = MTimer(MTimerID(rawValue: "Set Timer \(log.id)"))
        
        let total = Int(set.wrappedValue.time)
        self.hours = total / 3600
        self.minutes = (total % 3600) / 60
        self.seconds = total % 60
        
        self.distanceString = set.wrappedValue.distance.formatted()
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
                        log.unskip()
                        log.finish(time: set.time, distance: set.distance)
                        
                        if let restTimer = restTimer {
                            var time: Double = 0;
                            
                            switch (set.type) {
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
            }
            
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
                    TextField("Weight", text: $distanceString)
                        .keyboardType(.decimalPad)
                        .focused($isDistanceFocused)
                        .onChange(of: distanceString) {
                            distanceString = distanceString.filteredNumeric()
                            
                            if distanceString.isEmpty {
                                set.distance = 0
                            } else if distanceString.hasSuffix(".") {
                                set.distance = ("\(distanceString)0" as NSString).doubleValue
                            } else {
                                set.distance = (distanceString as NSString).doubleValue
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 125)
                    
                    Picker("Unit", selection: $set.unit) {
                        Text("mi").tag("mi")
                        
                        Text("km").tag("km")
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: 65, maxHeight: 100)
                    .clipped()
                    .padding(.leading, 5)
                }
                .frame(maxWidth: 190)
            }
            .padding(.bottom, 10)
            
            Picker("Type", selection: $set.type) {
                ForEach(ExerciseSetType.displayOrder, id: \.self) { type in
                    Text("\(type.rawValue)")
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .clipped()
            
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
                    isDistanceFocused = false
                } label: {
                    Text("Done")
                }
                .disabled(!isDistanceFocused)
            }
        }
    }
    
    func updateTime() {
        set.time = Double((hours * 3600) + (minutes * 60) + seconds)
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
