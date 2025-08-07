//
//  AddFoodEntryPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/4/25.
//

import SwiftUI
import SwiftData

struct AddFoodEntryPopup: View {
    @Environment(\.modelContext) private var context
    
    @State var log: CaloriesLog
    @State var entry: FoodEntry
    
    @Binding var foodAdded: Bool
    
    private let newEntry: Bool
    
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
    
    init(
        entry: FoodEntry = FoodEntry(
            name: "",
            calories: -1,
            carbs: 0,
            protein: 0,
            fat: 0
        ),
        log: CaloriesLog,
        foodAdded: Binding<Bool> = .constant(false)
    ) {
        if entry.calories == -1 {
            entry.calories = 0
            
            nameInput = ""
            caloriesInput = ""
            carbsInput = ""
            proteinInput = ""
            fatInput = ""
            
            newEntry = true
        } else {
            nameInput = entry.name
            caloriesInput = "\(entry.calories.formatted())"
            carbsInput = "\(entry.carbs.formatted())"
            proteinInput = "\(entry.protein.formatted())"
            fatInput = "\(entry.fat.formatted())"
            
            newEntry = false
        }
        
        self.entry = entry
        self.log = log
        
        self._foodAdded = foodAdded
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingL) {
            VStack(alignment: .center, spacing: .spacingM) {
                HStack(alignment: .center, spacing: .spacingM) {
                    Input(title: "Name", text: $nameInput, isFocused: _isNameFocused, autoCapitalization: .words)
                    
                    Input(
                        title: "Calories",
                        text: $caloriesInput,
                        isFocused: _isCaloriesFocused,
                        unit: "cal",
                        type: .decimalPad
                    )
                    .onChange(of: caloriesInput) {
                        caloriesInput = caloriesInput.filteredNumericWithoutDecimalPoint()
                    }
                }
                
                HStack(alignment: .center, spacing: .spacingS) {
                    Input(title: "Carbs", text: $carbsInput, isFocused: _isCarbsFocused, unit: "g", type: .decimalPad)
                        .onChange(of: carbsInput) {
                            carbsInput = carbsInput.filteredNumericWithoutDecimalPoint()
                        }
                    
                    Input(
                        title: "Protein",
                        text: $proteinInput,
                        isFocused: _isProteinFocused,
                        unit: "g",
                        type: .decimalPad
                    )
                    .onChange(of: proteinInput) {
                        proteinInput = proteinInput.filteredNumericWithoutDecimalPoint()
                    }
                    
                    Input(title: "Fat", text: $fatInput, isFocused: _isFatFocused, unit: "g", type: .decimalPad)
                        .onChange(of: fatInput) {
                            fatInput = fatInput.filteredNumericWithoutDecimalPoint()
                        }
                }
            }
            
            SaveButton(save: save, isValid: isValid)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
    }
    
    private func save() async {
        entry.name = nameInput
        entry.calories = round(Double(caloriesInput) ?? 0, 2)
        entry.carbs = round(Double(carbsInput) ?? 0, 2)
        entry.protein = round(Double(proteinInput) ?? 0, 2)
        entry.fat = round(Double(fatInput) ?? 0, 2)
        
        if newEntry {
            entry.caloriesLog = log
            
            context.insert(entry)
            
            NotificationManager.shared.cancelTodaysCalorieReminder()
        }
        
        do {
            try context.save()
            
            Toast.show("Food entry saved", "checkmark")
        } catch {
            debugLog("Error: \(error.localizedDescription)")
        }
        
        foodAdded = true
        
        Popup.dismissLast()
    }
}
