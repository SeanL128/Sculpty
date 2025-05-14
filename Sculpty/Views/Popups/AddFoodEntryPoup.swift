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
        
        self.log = log
        self.entry = entry
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("Name")
                        .bodyText(size: 12)
                        .textColor()
                    
                    TextField("", text: $nameInput)
                        .focused($isNameFocused)
                        .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isNameFocused }, set: { isNameFocused = $0 }), text: $nameInput))
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Calories")
                        .bodyText(size: 12)
                        .textColor()
                    
                    HStack(alignment: .bottom) {
                        TextField("", text: $caloriesInput)
                            .keyboardType(.numberPad)
                            .focused($isCaloriesFocused)
                            .textFieldStyle(UnderlinedTextFieldStyle(isFocused: Binding<Bool>(get: { isCaloriesFocused }, set: { isCaloriesFocused = $0 }), text: $caloriesInput))
                            .onChange(of: caloriesInput) {
                                caloriesInput = caloriesInput.filteredNumericWithoutDecimalPoint()
                            }
                        
                        Text("cal")
                            .bodyText(size: 16)
                            .textColor()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
            
            HStack(alignment: .center) {
                MacroTextField(title: "Carbs", value: $carbsInput, isFocused: _isCarbsFocused)
                
                MacroTextField(title: "Protein", value: $proteinInput, isFocused: _isProteinFocused)
                
                MacroTextField(title: "Fat", value: $fatInput, isFocused: _isFatFocused)
            }
            .padding(.bottom, 4)
            
            Button {
                save()
            } label: {
                Text("Save")
                    .bodyText(size: 18)
            }
            .disabled(!isValid)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .toolbar {
            ToolbarItemGroup (placement: .keyboard) {
                Spacer()
                
                Button {
                    isNameFocused = false
                    isCaloriesFocused = false
                    isCarbsFocused = false
                    isProteinFocused = false
                    isFatFocused = false
                } label: {
                    Text("Done")
                }
                .disabled(!(isNameFocused || isCaloriesFocused || isCarbsFocused || isProteinFocused || isFatFocused))
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
