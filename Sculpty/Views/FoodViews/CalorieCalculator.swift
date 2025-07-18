//
//  CalorieCalculator.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/16/25.
//

import SwiftUI

struct CalorieCalculator: View {
    @EnvironmentObject private var settings: CloudSettings
    
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
    
    private var dailyCalories: Int? {
        guard let ageInt = Int(age), let weightDouble = Double(weight) else {
            return 0
        }
        
        let heightCmDouble: Double

        if settings.units == "Imperial" {
            let feetToCm = (Double(heightFeet) ?? 0) * 30.48
            let inchesToCm = (Double(heightInches) ?? 0) * 2.54
            heightCmDouble = feetToCm + inchesToCm
        } else {
            heightCmDouble = Double(heightCm) ?? 0
        }
        
        let weightKg = settings.units == "Imperial" ? weightDouble * 0.453592 : weightDouble
        
        let bmr: Double
        if settings.gender == "Male" {
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
    
    @FocusState private var isAgeFocused: Bool
    @FocusState private var isWeightFocused: Bool
    @FocusState private var isHeightFeetFocused: Bool
    @FocusState private var isHeightInchesFocused: Bool
    @FocusState private var isHeightCmFocused: Bool
    
    var body: some View {
        ContainerView(title: "Calorie Calculator", spacing: 20) {
            // Age
            Input(title: "Age", text: $age, isFocused: _isAgeFocused, type: .numberPad)
                .onChange(of: age) {
                    age = age.filteredNumericWithoutDecimalPoint()
                }
            
            // Gender
            LabeledTypeSegmentedControl(
                label: "Geneder",
                size: 12,
                selection: $settings.gender,
                options: ["Male", "Female"],
                displayNames: ["Male", "Female"]
            )
            
            // Units
            LabeledButton(
                label: "Units",
                size: 12,
                action: {
                    Popup.show(content: {
                        UnitMenuPopup(selection: $settings.units)
                    })
                }
            ) {
                HStack(alignment: .center) {
                    Text(settings.units == "Imperial" ? "Imperial(mi, ft, in, lbs)" : "Metric (km, m, cm, kg)")
                        .bodyText(size: 18, weight: .bold)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(Font.system(size: 12, weight: .bold))
                }
            }
            
            // Weight
            Input(
                title: "Weight",
                text: $weight,
                isFocused: _isWeightFocused,
                unit: settings.units == "Imperial" ? "lbs" : "kg",
                type: .decimalPad
            )
            .onChange(of: weight) {
                weight = weight.filteredNumeric()
            }
            
            // Height Input
            if settings.units == "Imperial" {
                HStack(alignment: .bottom) {
                    Input(
                        title: "Height",
                        text: $heightFeet,
                        isFocused: _isHeightFeetFocused,
                        unit: "ft",
                        type: .numberPad
                    )
                    .onChange(of: heightFeet) {
                        heightFeet = heightFeet.filteredNumericWithoutDecimalPoint()
                    }
                    
                    Input(
                        title: "",
                        text: $heightInches,
                        isFocused: _isHeightInchesFocused,
                        unit: "in",
                        type: .numberPad
                    )
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
            
            // Activity Level Menu
            LabeledButton(
                label: "Activity Level",
                size: 12,
                action: {
                    Popup.show(content: {
                        MenuPopup(
                            title: "Activity Level",
                            options: ActivityLevel.stringDisplayOrder,
                            selection: $activityLevelString
                        )
                    })
                }
            ) {
                HStack(alignment: .center) {
                    Text(activityLevelString ?? "Moderate (3-5 days/week)")
                        .bodyText(size: 18, weight: .bold)
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12, weight: .bold))
                }
            }
            
            // Goal
            LabeledButton(
                label: "Goal",
                size: 12,
                action: {
                    Popup.show(content: {
                        MenuPopup(title: "Goal", options: Goal.stringDisplayOrder, selection: $goalString)
                    })
                }
            ) {
                HStack(alignment: .center) {
                    Text(goalString ?? "Maintain Weight")
                        .bodyText(size: 18, weight: .bold)
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .padding(.leading, -2)
                        .font(Font.system(size: 12, weight: .bold))
                }
            }
            
            Spacer()
                .frame(height: 5)
            
            HStack(spacing: 0) {
                Text("Daily Calories: ")
                    .bodyText(size: 16)
                
                Text(dailyCalories != nil ? "\(dailyCalories ?? 0)cal" : "N/A")
                    .statsText(size: 16)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: dailyCalories)
            }
            .textColor()

            Text("⚠️ The calorie estimates provided by this app are for reference purposes only and should not be considered medical advice. Consult a healthcare professional before making any significant changes to your diet or exercise routine.") // swiftlint:disable:this line_length
                .bodyText(size: 14)
                .secondaryColor()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
    }
}
