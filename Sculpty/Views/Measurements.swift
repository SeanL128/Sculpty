//
//  Measurements.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/11/25.
//

import SwiftUI
import SwiftData
import SwiftUICharts

struct Measurements: View {
    @State private var weightText: String = ""
    @State private var weightUnit: String = UnitsManager.weight
    @FocusState private var weightFocused: Bool
    
    @State private var bodyFatText: String = ""
    @FocusState private var bodyFatFocused: Bool
    
    @State private var neckText: String = ""
    @State private var neckUnit: String = UnitsManager.shortLength
    @FocusState private var neckFocused: Bool
    
    @State private var shouldersText: String = ""
    @State private var shouldersUnit: String = UnitsManager.shortLength
    @FocusState private var shouldersFocused: Bool
    
    @State private var chestText: String = ""
    @State private var chestUnit: String = UnitsManager.shortLength
    @FocusState private var chestFocused: Bool
    
    @State private var upperArmLeftText: String = ""
    @State private var upperArmLeftUnit: String = UnitsManager.shortLength
    @FocusState private var upperArmLeftFocused: Bool
    
    @State private var upperArmRightText: String = ""
    @State private var upperArmRightUnit: String = UnitsManager.shortLength
    @FocusState private var upperArmRightFocused: Bool
    
    @State private var forearmLeftText: String = ""
    @State private var forearmLeftUnit: String = UnitsManager.shortLength
    @FocusState private var forearmLeftFocused: Bool
    
    @State private var forearmRightText: String = ""
    @State private var forearmRightUnit: String = UnitsManager.shortLength
    @FocusState private var forearmRightFocused: Bool
    
    @State private var waistText: String = ""
    @State private var waistUnit: String = UnitsManager.shortLength
    @FocusState private var waistFocused: Bool
    
    @State private var hipsText: String = ""
    @State private var hipsUnit: String = UnitsManager.shortLength
    @FocusState private var hipsFocused: Bool
    
    @State private var thighLeftText: String = ""
    @State private var thighLeftUnit: String = UnitsManager.shortLength
    @FocusState private var thighLeftFocused: Bool
    
    @State private var thighRightText: String = ""
    @State private var thighRightUnit: String = UnitsManager.shortLength
    @FocusState private var thighRightFocused: Bool
    
    @State private var calfLeftText: String = ""
    @State private var calfLeftUnit: String = UnitsManager.shortLength
    @FocusState private var calfLeftFocused: Bool
    
    @State private var calfRightText: String = ""
    @State private var calfRightUnit: String = UnitsManager.shortLength
    @FocusState private var calfRightFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    HStack {
                        Text("Measurements")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                    }
                    .padding()
                    
                    List {
                        Section {
                            NavigationLink {
                                MeasurementPage(title: "Weight", type: .weight, text: $weightText, unit: $weightUnit, isFocused: _weightFocused)
                            } label: {
                                Text("Weight")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Body Fat Percentage", type: .bodyFat, text: $bodyFatText, unit: .constant("%"), isFocused: _bodyFatFocused)
                            } label: {
                                Text("Body Fat Percentage")
                            }
                        }
                        
                        Section {
                            NavigationLink {
                                MeasurementPage(title: "Neck", type: .neck, text: $neckText, unit: $neckUnit, isFocused: _neckFocused)
                            } label: {
                                Text("Neck")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Shoulders", type: .shoulders, text: $shouldersText, unit: $shouldersUnit, isFocused: _shouldersFocused)
                            } label: {
                                Text("Shoulders")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Chest", type: .chest, text: $chestText, unit: $chestUnit, isFocused: _chestFocused)
                            } label: {
                                Text("Chest")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Upper Arm (Left)", type: .upperArmLeft, text: $upperArmLeftText, unit: $upperArmLeftUnit, isFocused: _upperArmLeftFocused)
                            } label: {
                                Text("Upper Arm (Left)")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Upper Arm (Right)", type: .upperArmRight, text: $upperArmRightText, unit: $upperArmRightUnit, isFocused: _upperArmRightFocused)
                            } label: {
                                Text("Upper Arm (Right)")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Forearm (Left)", type: .forearmLeft, text: $forearmLeftText, unit: $forearmLeftUnit, isFocused: _forearmLeftFocused)
                            } label: {
                                Text("Forearm (Left)")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Forearm (Right)", type: .forearmRight, text: $forearmRightText, unit: $forearmRightUnit, isFocused: _forearmRightFocused)
                            } label: {
                                Text("Forearm (Right)")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Waist", type: .waist, text: $waistText, unit: $waistUnit, isFocused: _waistFocused)
                            } label: {
                                Text("Waist")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Hips", type: .hips, text: $hipsText, unit: $hipsUnit, isFocused: _hipsFocused)
                            } label: {
                                Text("Hips")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Thigh (Left)", type: .thighLeft, text: $thighLeftText, unit: $thighLeftUnit, isFocused: _thighLeftFocused)
                            } label: {
                                Text("Thigh (Left)")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Thigh (Right)", type: .thighRight, text: $thighRightText, unit: $thighRightUnit, isFocused: _thighRightFocused)
                            } label: {
                                Text("Thigh (Right)")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Calf (Left)", type: .calfLeft, text: $calfLeftText, unit: $calfLeftUnit, isFocused: _calfLeftFocused)
                            } label: {
                                Text("Calf (Left)")
                            }
                            
                            NavigationLink {
                                MeasurementPage(title: "Calf (Right)", type: .calfRight, text: $calfRightText, unit: $calfRightUnit, isFocused: _calfRightFocused)
                            } label: {
                                Text("Calf (Right)")
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .padding()
            }
        }
    }
}

#Preview {
    Measurements()
}
