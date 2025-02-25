//
//  CalorieCalculator.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/16/25.
//

import SwiftUI
import Neumorphic

struct CalorieCalculator: View {
    @State private var age: String = ""
    @State private var selectedGender: Gender = .male
    @State private var selectedUnits: UnitOptions = .imperial
    @State private var weight: String = ""
    @State private var heightFeet: String = ""
    @State private var heightInches: String = ""
    @State private var heightCm: String = ""
    @State private var selectedActivityLevel: ActivityLevel = .moderate
    @State private var goal: Goal = .maintain
    @State private var dailyCalories: Int?
    
    @FocusState private var ageFocused: Bool
    @FocusState private var weightFocused: Bool
    @FocusState private var heightFeetFocused: Bool
    @FocusState private var heightInchesFocused: Bool
    @FocusState private var heightCmFocused: Bool
    
    @AppStorage(UserKeys.units.rawValue) private var units: String = "Imperial"
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                ScrollView {
                    HStack {
                        Text("Daily Caloric Intake")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 25) {
                        TextField("", text: $age, prompt: Text("Age").foregroundColor(.secondary))
                            .keyboardType(.numberPad)
                            .focused($ageFocused)
                            .padding(8)
                            .padding(.horizontal, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                    .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.25, radius: 2)
                            )
                            .onChange(of: age) {
                                age = age.filteredNumericWithoutDecimalPoint()
                            }
                        
                        VStack(spacing: 20) {
                            HStack {
                                Toggle(isOn: Binding(
                                    get: { selectedGender == .male },
                                    set: { if $0 { selectedGender = .male } }
                                )) {
                                    Text("Male")
                                        .frame(width: 65)
                                }
                                .softToggleStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)

                                Toggle(isOn: Binding(
                                    get: { selectedGender == .female },
                                    set: { if $0 { selectedGender = .female } }
                                )) {
                                    Text("Female")
                                        .frame(width: 65)
                                }
                                .softToggleStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )
                        
                        VStack(spacing: 20) {
                            HStack {
                                Toggle(isOn: Binding(
                                    get: { selectedUnits == .imperial },
                                    set: { if $0 { selectedUnits = .imperial } }
                                )) {
                                    Text("Imperial")
                                        .frame(width: 75)
                                }
                                .softToggleStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)

                                Toggle(isOn: Binding(
                                    get: { selectedUnits == .metric },
                                    set: { if $0 { selectedUnits = .metric } }
                                )) {
                                    Text("Metric")
                                        .frame(width: 75)
                                }
                                .softToggleStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                            }
                            .onChange(of: selectedUnits) {
                                units = selectedUnits.rawValue
                            }
                            
                            // Weight Input
                            TextField("", text: $weight, prompt: Text(selectedUnits == .imperial ? "Weight (lbs)" : "Weight (kg)").foregroundColor(.secondary))
                                .keyboardType(.decimalPad)
                                .focused($weightFocused)
                                .padding(8)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                        .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.25, radius: 2)
                                )
                                .onChange(of: weight) {
                                    weight = weight.filteredNumeric()
                                }
                            
                            // Height Input
                            if selectedUnits == .imperial {
                                HStack {
                                    TextField("", text: $heightFeet, prompt: Text("Height (ft)").foregroundColor(.secondary))
                                        .keyboardType(.numberPad)
                                        .focused($heightFeetFocused)
                                        .padding(8)
                                        .padding(.horizontal, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.25, radius: 2)
                                        )
                                        .onChange(of: heightFeet) {
                                            heightFeet = heightFeet.filteredNumericWithoutDecimalPoint()
                                        }

                                    TextField("", text: $heightInches, prompt: Text("Height (in)").foregroundColor(.secondary))
                                        .keyboardType(.numberPad)
                                        .focused($heightInchesFocused)
                                        .padding(8)
                                        .padding(.horizontal, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                                .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.25, radius: 2)
                                        )
                                        .onChange(of: heightInches) {
                                            heightInches = heightInches.filteredNumericWithoutDecimalPoint()
                                        }
                                }
                            } else {
                                TextField("", text: $heightCm, prompt: Text("Height (cm)").foregroundColor(.secondary))
                                    .keyboardType(.numberPad)
                                    .focused($heightCmFocused)
                                    .padding(8)
                                    .padding(.horizontal, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                            .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.25, radius: 2)
                                    )
                                    .onChange(of: heightCm) {
                                        heightCm = heightCm.filteredNumericWithoutDecimalPoint()
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )
                        
                        // Activity Level Picker
                        VStack(spacing: 5) {
                            Text("Activity Level")
                                .font(.callout)
                            
                            Picker("Activity Level", selection: $selectedActivityLevel) {
                                ForEach(ActivityLevel.allCases, id: \.self) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(ColorManager.text)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )
                        
                        VStack(spacing: 5) {
                            Text("Goal")
                                .font(.callout)
                            
                            Picker("Goal", selection: $goal) {
                                ForEach(Goal.allCases, id: \..self) { g in
                                    Text(g.rawValue).tag(g)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(ColorManager.text)
                            
                            Button("Calculate Calories") {
                                dailyCalories = calculateCalories()
                            }
                            .softButtonStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                            
                            if let calories = dailyCalories {
                                Text("Daily Calories: \(calories)")
                                    .font(.title3)
                                    .padding(.top)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                .softOuterShadow(darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, radius: 2)
                        )

                        Text("⚠️ The calorie estimates provided by this app are for informational purposes only and should not be considered medical advice. Consult a healthcare professional or registered dietitian before making any significant changes to your diet or exercise routine.")
                            .font(.caption)
                            .italic()
                    }
                }
                .scrollClipDisabled()
                .padding()
            }
            .toolbarBackground(ColorManager.background)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button {
                        ageFocused = false
                        weightFocused = false
                        heightFeetFocused = false
                        heightInchesFocused = false
                        heightCmFocused = false
                    } label: {
                        Text("Done")
                    }
                    .disabled(!(ageFocused || weightFocused || heightFeetFocused || heightInchesFocused || heightCmFocused))
                }
            }
        }
    }
    
    func calculateCalories() -> Int {
        guard let ageInt = Int(age), let weightDouble = Double(weight) else {
            return 0
        }
        
        let heightCmDouble: Double = selectedUnits == .imperial ? ((Double(heightFeet) ?? 0) * 30.48 + (Double(heightInches) ?? 0) * 2.54) : (Double(heightCm) ?? 0)
        
        let weightKg = selectedUnits == .imperial ? weightDouble * 0.453592 : weightDouble
        
        let bmr: Double
        if selectedGender == .male {
            bmr = 88.36 + (13.4 * weightKg) + (4.8 * heightCmDouble) - (5.7 * Double(ageInt))
        } else {
            bmr = 447.6 + (9.2 * weightKg) + (3.1 * heightCmDouble) - (4.3 * Double(ageInt))
        }
        
        let activityMultipliers: [ActivityLevel: Double] = [
            .sedentary: 1.2,
            .light: 1.375,
            .moderate: 1.55,
            .active: 1.725,
            .veryActive: 1.9
        ]
        
        let tdee = bmr * (activityMultipliers[selectedActivityLevel] ?? 1.55)
        
        switch goal {
        case .lose: return Int(tdee - 500)
        case .maintain: return Int(tdee)
        case .gain: return Int(tdee + 500)
        }
    }
}

enum Gender {
    case male, female
}

enum UnitOptions: String {
    case imperial = "Imperial"
    case metric = "Metric"
}

enum ActivityLevel: String, CaseIterable {
    case sedentary = "Sedentary (little or no exercise)"
    case light = "Light (1-3 days/week)"
    case moderate = "Moderate (3-5 days/week)"
    case active = "Active (6-7 days/week)"
    case veryActive = "Very Active (athlete, intense training)"
}

enum Goal: String, CaseIterable {
    case lose = "Lose Weight"
    case maintain = "Maintain Weight"
    case gain = "Gain Weight"
}

#Preview {
    CalorieCalculator()
}
