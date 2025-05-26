//
//  AddFoodEntryPoup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/4/25.
//

import SwiftUI
import SwiftData
import MijickPopups

struct AddFoodEntryPoup: CenterPopup {
    @Environment(\.modelContext) private var context
    
    @State var log: CaloriesLog
    @State var entry: FoodEntry
    
    private var newEntry: Bool = true
    
    @State private var nameInput: String = ""
    @FocusState private var isNameFocused: Bool
    
    @State private var caloriesInput: String = ""
    @FocusState private var isCaloriesFocused: Bool
    
    @State private var carbsInput: String = ""
    @FocusState private var isCarbsFocused: Bool
    
    @State private var proteinInput: String = ""
    @FocusState private var isProteinFocused: Bool
    
    @State private var fatInput: String = ""
    @FocusState private var isFatFocused: Bool
    
    var isValid: Bool {
        !nameInput.isEmpty &&
        !caloriesInput.isEmpty &&
        !carbsInput.isEmpty &&
        !proteinInput.isEmpty &&
        !fatInput.isEmpty
    }
    
    init(entry: FoodEntry = FoodEntry(name: "", calories: 0, carbs: 0, protein: 0, fat: 0), log: CaloriesLog) {
        if entry.name != "" {
            nameInput = entry.name
            caloriesInput = "\(entry.calories.formatted())"
            carbsInput = "\(entry.carbs.formatted())"
            proteinInput = "\(entry.protein.formatted())"
            fatInput = "\(entry.fat.formatted())"
            
            newEntry = false
        }
        
        self.entry = entry
        self.log = log
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack(alignment: .center) {
                Input(title: "Name", text: $nameInput, isFocused: _isNameFocused, autoCapitalization: .words)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                
                Input(title: "Calories", text: $caloriesInput, isFocused: _isCaloriesFocused, unit: "cal", type: .numberPad)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .onChange(of: caloriesInput) {
                        caloriesInput = caloriesInput.filteredNumericWithoutDecimalPoint()
                    }
            }
            
            HStack(alignment: .center) {
                Input(title: "Carbs", text: $carbsInput, isFocused: _isCarbsFocused, unit: "g", type: .numberPad)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .onChange(of: carbsInput) {
                        carbsInput = carbsInput.filteredNumericWithoutDecimalPoint()
                    }
                
                Input(title: "Protein", text: $proteinInput, isFocused: _isProteinFocused, unit: "g", type: .numberPad)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .onChange(of: proteinInput) {
                        proteinInput = proteinInput.filteredNumericWithoutDecimalPoint()
                    }
                
                Input(title: "Fat", text: $fatInput, isFocused: _isFatFocused, unit: "g", type: .numberPad)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .onChange(of: fatInput) {
                        fatInput = fatInput.filteredNumericWithoutDecimalPoint()
                    }
            }
            .padding(.bottom, 4)
            
            Button {
                save()
            } label: {
                Text("Save")
                    .bodyText(size: 18)
            }
            .textColor()
            .disabled(!isValid)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .toolbar {
            ToolbarItemGroup (placement: .keyboard) {
                Spacer()
                
                KeyboardDoneButton(focusStates: [_isNameFocused, _isCaloriesFocused, _isCarbsFocused, _isProteinFocused, _isFatFocused])
            }
        }
    }
    
    private func save() {
        entry.name = nameInput
        entry.calories = Double(caloriesInput) ?? 0
        entry.carbs = Double(carbsInput) ?? 0
        entry.protein = Double(proteinInput) ?? 0
        entry.fat = Double(fatInput) ?? 0
        
        if newEntry {
            entry.caloriesLog = log
            
            context.insert(entry)
        }
        
        try? context.save()
        
        nameInput = ""
        caloriesInput = ""
        carbsInput = ""
        proteinInput = ""
        fatInput = ""
        
        Task {
            await dismissLastPopup()
        }
    }
    
    func configurePopup(config: CenterPopupConfig) -> CenterPopupConfig {
        config
            .backgroundColor(ColorManager.background)
            .popupHorizontalPadding(24)
    }
}
