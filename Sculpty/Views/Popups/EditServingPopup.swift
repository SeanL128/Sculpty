//
//  EditServingPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI

struct EditServingPopup: View {
    @Binding var serving: CustomServing
    
    @State private var descriptionInput: String = ""
    @FocusState private var isDescriptionFocused: Bool
    
    @State private var caloriesInput: String = ""
    @FocusState private var isCaloriesFocused: Bool
    
    @State private var carbsInput: String = ""
    @FocusState private var isCarbsFocused: Bool
    
    @State private var proteinInput: String = ""
    @FocusState private var isProteinFocused: Bool
    
    @State private var fatInput: String = ""
    @FocusState private var isFatFocused: Bool
    
    init(serving: Binding<CustomServing>) {
        self._serving = serving
        
        let s = serving.wrappedValue
        _descriptionInput = State(initialValue: s.desc)
        _caloriesInput = State(initialValue: "\(s.calories.formatted())")
        _carbsInput = State(initialValue: "\(s.carbs.formatted())")
        _proteinInput = State(initialValue: "\(s.protein.formatted())")
        _fatInput = State(initialValue: "\(s.fat.formatted())")
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingL) {
            VStack(alignment: .center, spacing: .spacingM) {
                HStack(alignment: .center, spacing: .spacingM) {
                    Input(
                        title: "Serving Size",
                        text: $descriptionInput,
                        isFocused: _isDescriptionFocused,
                        autoCapitalization: .words
                    )
                    .onChange(of: descriptionInput) {
                        serving.desc = descriptionInput
                    }
                    
                    Input(
                        title: "Calories",
                        text: $caloriesInput,
                        isFocused: _isCaloriesFocused,
                        unit: "cal",
                        type: .numberPad
                    )
                    .onChange(of: caloriesInput) {
                        caloriesInput = caloriesInput.filteredNumericWithoutDecimalPoint()
                        
                        serving.calories = Double(caloriesInput) ?? 0
                    }
                }
                
                HStack(alignment: .center, spacing: .spacingS) {
                    Input(title: "Carbs", text: $carbsInput, isFocused: _isCarbsFocused, unit: "g", type: .numberPad)
                        .onChange(of: carbsInput) {
                            carbsInput = carbsInput.filteredNumericWithoutDecimalPoint()
                            
                            serving.carbs = Double(carbsInput) ?? 0
                        }
                    
                    Input(
                        title: "Protein",
                        text: $proteinInput,
                        isFocused: _isProteinFocused,
                        unit: "g",
                        type: .numberPad
                    )
                    .onChange(of: proteinInput) {
                        proteinInput = proteinInput.filteredNumericWithoutDecimalPoint()
                        
                        serving.protein = Double(proteinInput) ?? 0
                    }
                    
                    Input(title: "Fat", text: $fatInput, isFocused: _isFatFocused, unit: "g", type: .numberPad)
                        .onChange(of: fatInput) {
                            fatInput = fatInput.filteredNumericWithoutDecimalPoint()
                            
                            serving.fat = Double(fatInput) ?? 0
                        }
                }
            }
            
            VStack(alignment: .center, spacing: .spacingM) {
                Spacer()
                    .frame(height: 0)
                
                Button {
                    Popup.dismissLast()
                } label: {
                    Text("OK")
                        .bodyText()
                        .padding(.vertical, 12)
                        .padding(.horizontal, .spacingL)
                }
                .textColor()
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .animatedButton(feedback: .selection)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
    }
}
