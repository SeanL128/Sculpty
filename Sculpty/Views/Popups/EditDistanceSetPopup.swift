//
//  EditDistanceSetPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/24/25.
//

import SwiftUI

struct EditDistanceSetPopup: View {
    @EnvironmentObject private var settings: CloudSettings
    
    var set: ExerciseSet
    @Binding var log: SetLog
    
    @State private var referenceHeight: CGFloat = 0
    
    private let restTime: Double
    private let restTimer: RestTimer?

    @StateObject private var setTimer = SetTimer()
    
    @State private var disableType: Bool = false
    
    @State private var updatedSet: ExerciseSet
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    @State private var distanceString: String
    
    @FocusState private var isDistanceFocused: Bool
    
    init (set: ExerciseSet,
          log: Binding<SetLog> = .constant(SetLog(index: -1, set: ExerciseSet(), unit: UnitsManager.longLength)),
          restTime: Double = 0,
          timer: RestTimer? = nil,
          disableType: Bool = false) {
        self.set = set
        self._log = log
        
        self.restTime = restTime
        restTimer = timer
        
        self.disableType = disableType
        
        _updatedSet = State(initialValue: set)
        
        let total = Int(set.time ?? 0)
        hours = total / 3600
        minutes = (total % 3600) / 60
        seconds = total % 60
        
        distanceString = (set.distance ?? 0).formatted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            // Header
            HStack(alignment: .center, spacing: .spacingL) {
                Spacer()
                
                if log.index > -1 {
                    Button {
                        log.unfinish()
                        log.skip()
                        
                        Popup.dismissLast()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.right.fill")
                            .headingImage()
                    }
                    .textColor()
                    .animatedButton(feedback: .impact(weight: .light))
                }
                
                Button {
                    if log.index > -1 {
                        log.unskip()
                        log.finish(time: (updatedSet.time ?? 0), distance: (updatedSet.distance ?? 0))
                        
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
                    
                    Popup.dismissLast()
                } label: {
                    Image(systemName: "checkmark")
                        .headingImage()
                }
                .textColor()
                .animatedButton(feedback: .success)
            }
            
            HStack(alignment: .center, spacing: .spacingM) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Duration")
                        .captionText()
                        .textColor()
                    
                    Spacer()
                    
                    Button {
                        Popup.show(content: {
                            DurationSelectionPopup(
                                title: "Duration",
                                hours: $hours,
                                minutes: $minutes,
                                seconds: $seconds
                            )
                        })
                    } label: {
                        HStack(alignment: .center, spacing: .spacingXS) {
                            Text("\(hours)hr \(minutes)min \(seconds)sec")
                                .bodyText(weight: .regular)
                            
                            Image(systemName: "chevron.right")
                                .bodyImage()
                        }
                    }
                    .textColor()
                    .onChange(of: hours) { updateTime() }
                    .onChange(of: minutes) { updateTime() }
                    .onChange(of: seconds) { updateTime() }
                    .animatedButton()
                    .padding(.bottom, .spacingS)
                }
                .frame(maxWidth: 200, maxHeight: referenceHeight)
                
                HStack(alignment: .bottom, spacing: 0) {
                    Input(
                        title: "Distance",
                        text: $distanceString,
                        isFocused: _isDistanceFocused,
                        type: .decimalPad
                    )
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
                    .frame(maxWidth: 150)
                    .background(GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                referenceHeight = geo.size.height
                            }
                            .onChange(of: geo.size.height) {
                                referenceHeight = geo.size.height
                            }
                    })
                    
                    Button {
                        Popup.show(content: {
                            SmallMenuPopup(title: "Units", options: ["mi", "km"], selection: $updatedSet.unit)
                        })
                    } label: {
                        HStack(alignment: .center, spacing: .spacingXS) {
                            Text(updatedSet.unit)
                                .bodyText(weight: .regular)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .bodyImage(weight: .medium)
                        }
                    }
                    .textColor()
                    .frame(maxWidth: 65)
                    .animatedButton()
                }
                .frame(maxWidth: 190)
            }
            
            if !disableType {
                TypedSegmentedControl(
                    selection: $updatedSet.type,
                    options: ExerciseSetType.displayOrder,
                    displayNames: ExerciseSetType.stringDisplayOrder
                )
            }
            
            if log.index > -1 && settings.showSetTimer {
                HStack(alignment: .center, spacing: .spacingS) {
                    Text(setTimer.timeString())
                        .subheadingText()
                    
                    Spacer()
                    
                    Button {
                        if setTimer.status == .notStarted {
                            setTimer.start()
                        } else if setTimer.status == .paused {
                            setTimer.resume()
                        } else {
                            setTimer.pause()
                        }
                    } label: {
                        Image(systemName: (setTimer.status == .notStarted || setTimer.status == .paused) ? "play.fill" : "pause.fill") // swiftlint:disable:this line_length
                            .bodyText(weight: .regular)
                            .padding(.vertical, -2)
                            .frame(width: 15)
                    }
                    .textColor()
                    .filledToBorderedButton(
                        scale: 0.95,
                        feedback: [.notStarted, .paused].contains(setTimer.status) ? .start : .stop
                    )
                    
                    Button {
                        setTimer.cancel()
                    } label: {
                        Image(systemName: "stop.fill")
                            .bodyText(weight: .regular)
                            .padding(.vertical, -2)
                            .frame(width: 15)
                    }
                    .buttonStyle(FilledToBorderedButtonStyle())
                    .disabled(setTimer.status != .running && setTimer.status != .paused)
                    .filledToBorderedButton(
                        scale: 0.95,
                        feedback: .stop,
                        isValid: setTimer.status == .running || setTimer.status == .paused
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
    
    func updateTime() {
        updatedSet.time = Double((hours * 3600) + (minutes * 60) + seconds)
    }
}
