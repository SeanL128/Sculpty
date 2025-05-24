//
//  CalorieCalculator.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/16/25.
//

import SwiftUI
import BRHSegmentedControl

struct CalorieCalculator: View {
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var heightFeet: String = ""
    @State private var heightInches: String = ""
    @State private var heightCm: String = ""
    @State private var activityLevelString: String? = "Moderate (3-5 days/week)"
    private var activityLevel: ActivityLevel {
        ActivityLevel(rawValue: activityLevelString ?? "Moderate (3-5 days/week)") ?? .moderate
    }
    @State private var goalString: String? = "Maintain Weight"
    private var goal: Goal {
        Goal(rawValue: goalString ?? "Maintain Weight") ?? .maintain
    }
    @State private var dailyCalories: Int?
    
    @FocusState private var isAgeFocused: Bool
    @FocusState private var isWeightFocused: Bool
    @FocusState private var isHeightFeetFocused: Bool
    @FocusState private var isHeightInchesFocused: Bool
    @FocusState private var isHeightCmFocused: Bool
    
    @State private var selectedGenderIndex: Int = UserDefaults.standard.object(forKey: UserKeys.gender.rawValue) as? String == "Male" ? 0 : 1
    private let genderOptionsMap: [Int: Gender] = [
        0: .male,
        1: .female
    ]
    private var selectedGender: Gender {
        get { genderOptionsMap[selectedGenderIndex] ?? .male }
        set {
            if newValue == .female {
                selectedGenderIndex = 1
            } else {
                selectedGenderIndex = 0
            }
        }
    }
    
    @State private var selectedUnitsIndex: Int = UserDefaults.standard.object(forKey: UserKeys.units.rawValue) as? String == "Metric" ? 1 : 0
    private let unitOptionsMap: [Int: UnitOptions] = [
        0: .imperial,
        1: .metric
    ]
    private var selectedUnits: UnitOptions {
        get { unitOptionsMap[selectedUnitsIndex] ?? .imperial }
        set {
            if newValue == .metric {
                selectedUnitsIndex = 1
            } else {
                selectedUnitsIndex = 0
            }
        }
    }
    
    @AppStorage(UserKeys.units.rawValue) private var units: String = "Imperial"
    
    var body: some View {
        ContainerView(title: "Calorie Calculator", spacing: 20) {
            // Age
            Input(title: "Age", text: $age, isFocused: _isAgeFocused, type: .numberPad)
                .onChange(of: age) {
                    age = age.filteredNumericWithoutDecimalPoint()
                }
            
            // Gender
            VStack(alignment: .leading) {
                Text("Gender")
                    .bodyText(size: 12)
                    .textColor()
                
                BRHSegmentedControl(
                    selectedIndex: $selectedGenderIndex,
                    labels: ["Male", "Female"],
                    builder: { _, label in
                        Text(label)
                            .bodyText(size: 16)
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
                .onChange(of: selectedGenderIndex) {
                    let genderOption = genderOptionsMap[selectedGenderIndex] ?? .male
                    UserDefaults.standard.set(genderOption.rawValue, forKey: UserKeys.gender.rawValue)
                }
            }
            
            // Units
            VStack(alignment: .leading) {
                Text("Units")
                    .bodyText(size: 12)
                    .textColor()
                
                BRHSegmentedControl(
                    selectedIndex: $selectedUnitsIndex,
                    labels: ["Imperial", "Metric"],
                    builder: { _, label in
                        Text(label)
                            .bodyText(size: 16)
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
                .onChange(of: selectedUnitsIndex) {
                    let unitOption = unitOptionsMap[selectedUnitsIndex] ?? .imperial
                    UserDefaults.standard.set(unitOption.rawValue, forKey: UserKeys.units.rawValue)
                    
                    units = selectedUnits.rawValue
                }
            }
            
            // Weight
            Input(title: "Weight", text: $weight, isFocused: _isWeightFocused, unit: selectedUnits == .imperial ? "lbs" : "kg", type: .decimalPad)
                .onChange(of: weight) {
                    weight = weight.filteredNumeric()
                }
            
            // Height Input
            if selectedUnits == .imperial {
                HStack(alignment: .bottom) {
                    Input(title: "Height", text: $heightFeet, isFocused: _isHeightFeetFocused, unit: "ft", type: .numberPad)
                        .onChange(of: heightFeet) {
                            heightFeet = heightFeet.filteredNumericWithoutDecimalPoint()
                        }
                    
                    Input(title: "", text: $heightInches, isFocused: _isHeightInchesFocused, unit: "in", type: .numberPad)
                        .onChange(of: heightInches) {
                            heightInches = heightInches.filteredNumeric()
                        }
                }
            } else {
                Input(title: "Height", text: $heightCm, isFocused: _isHeightCmFocused, unit: "cm", type: .numberPad)
                    .onChange(of: heightCm) {
                        heightCm = heightCm.filteredNumericWithoutDecimalPoint()
                    }
            }
            
            // Activity Level Picker
            VStack(alignment: .leading) {
                Text("Activity Level")
                    .bodyText(size: 12)
                    .textColor()
                
                Button {
                    Task {
                        await MenuPopup(title: "Activity Level", options: ActivityLevel.stringDisplayOrder, selection: $activityLevelString).present()
                    }
                } label: {
                    HStack(alignment: .center) {
                        Text(activityLevelString ?? "Moderate (3-5 days/week)")
                            .bodyText(size: 16)
                            .multilineTextAlignment(.leading)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 10))
                    }
                }
                .textColor()
            }
            
            // Goal
            VStack(alignment: .leading) {
                Text("Goal")
                    .bodyText(size: 12)
                    .textColor()
                
                Button {
                    Task {
                        await MenuPopup(title: "Goal", options: Goal.stringDisplayOrder, selection: $goalString).present()
                    }
                } label: {
                    HStack(alignment: .center) {
                        Text("Goal: \(goalString ?? "Maintain Weight")")
                            .bodyText(size: 16)
                            .multilineTextAlignment(.leading)
                        
                        Image(systemName: "chevron.right")
                            .padding(.leading, -2)
                            .font(Font.system(size: 10))
                    }
                }
                .textColor()
            }
            
            // Calculate Button
            Button {
                dailyCalories = calculateCalories()
            } label: {
                Text("Calculate Calories")
                    .bodyText(size: 18)
            }
            
            Spacer()
                .frame(height: 5)
            
            HStack(spacing: 0) {
                Text("Daily Calories: ")
                    .bodyText(size: 14)
                
                Text(dailyCalories != nil ? "\(dailyCalories ?? 0)cal" : "N/A")
                    .statsText(size: 14)
            }
            .textColor()
            
            Spacer()
                .frame(height: 5)

            Text("⚠️ The calorie estimates provided by this app are for reference purposes only and should not be considered medical advice. Consult a healthcare professional before making any significant changes to your diet or exercise routine.")
                .bodyText(size: 14)
                .secondaryColor()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button {
                    isAgeFocused = false
                    isWeightFocused = false
                    isHeightFeetFocused = false
                    isHeightInchesFocused = false
                    isHeightCmFocused = false
                } label: {
                    Text("Done")
                }
                .disabled(!(isAgeFocused || isWeightFocused || isHeightFeetFocused || isHeightInchesFocused || isHeightCmFocused))
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
        
        let tdee = bmr * (activityMultipliers[activityLevel] ?? 1.55)
        
        switch goal {
        case .lose: return Int(tdee - 500)
        case .maintain: return Int(tdee)
        case .gain: return Int(tdee + 500)
        }
    }
}

enum Gender: String {
    case male = "Male"
    case female = "Female"
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
    
    static let displayOrder: [ActivityLevel] = [
        .sedentary, .light, .moderate, .active, .veryActive
    ]
    
    static let stringDisplayOrder: [String] = displayOrder.map(\.self.rawValue)
}

enum Goal: String, CaseIterable {
    case lose = "Lose Weight"
    case maintain = "Maintain Weight"
    case gain = "Gain Weight"
    
    static let displayOrder: [Goal] = [
        .lose, .maintain, .gain
    ]
    
    static let stringDisplayOrder: [String] = displayOrder.map(\.self.rawValue)
}

#Preview {
    CalorieCalculator()
}
