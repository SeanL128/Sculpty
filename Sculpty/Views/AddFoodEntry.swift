//
//  AddFoodEntry.swift
//  Sculpty
//
//  Created by Sean Lindsay on 3/9/25.
//

import SwiftUI
import SwiftData
import Neumorphic

struct AddFoodEntry: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State var log: CaloriesLog
    @State var entry: FoodEntry
    
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
            self.nameInput = entry.name
            self.caloriesInput = "\(entry.calories.formatted())"
            self.carbsInput = "\(entry.carbs.formatted())"
            self.proteinInput = "\(entry.protein.formatted())"
            self.fatInput = "\(entry.fat.formatted())"
        }
        
        self.log = log
        self.entry = entry
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorManager.background
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    HStack {
                        VStack {
                            HStack {
                                Text("Name")
                                    .font(.footnote)
                                
                                Spacer()
                            }
                            
                            TextField("", text: $nameInput)
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                                .focused($isNameFocused)
                                .background(
                                    RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                        .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                                )
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        
                        VStack {
                            HStack {
                                Text("Calories")
                                    .font(.footnote)
                                
                                Spacer()
                            }
                            
                            HStack {
                                TextField("", text: $caloriesInput)
                                    .keyboardType(.numberPad)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    .focused($isCaloriesFocused)
                                    .onChange(of: caloriesInput) {
                                        caloriesInput = caloriesInput.filteredNumericWithoutDecimalPoint()
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: 15).fill(ColorManager.background)
                                            .softInnerShadow(RoundedRectangle(cornerRadius: 15), darkShadow: ColorManager.darkShadow, lightShadow: ColorManager.lightShadow, spread: 0.05, radius: 2)
                                    )
                                
                                Text("cal")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                    
                    HStack {
                        MacroTextField(title: "Carbs", value: $carbsInput, isFocused: _isCarbsFocused)
                            .padding(.trailing, 10)
                        MacroTextField(title: "Protein", value: $proteinInput, isFocused: _isProteinFocused)
                            .padding(.horizontal, 5)
                        MacroTextField(title: "Fat", value: $fatInput, isFocused: _isFatFocused)
                            .padding(.leading, 10)
                    }
                    .padding(.bottom, 10)
                    
                    Button {
                        save()
                    } label: {
                        Text("Save")
                    }
                    .softButtonStyle(.capsule, mainColor: ColorManager.background, textColor: ColorManager.text, darkShadowColor: ColorManager.darkShadow, lightShadowColor: ColorManager.lightShadow)
                    .disabled(!isValid)
                    
                    Spacer()
                }
                .padding()
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
        }
    }
    
    private func save() {
        entry.name = nameInput
        entry.calories = Double(caloriesInput) ?? 0
        entry.carbs = Double(carbsInput) ?? 0
        entry.protein = Double(proteinInput) ?? 0
        entry.fat = Double(fatInput) ?? 0
        
        if !log.entries.contains(entry) {
            context.insert(entry)
            log.entries.append(entry)
        }
        
        nameInput = ""
        caloriesInput = ""
        carbsInput = ""
        proteinInput = ""
        fatInput = ""
        
        try? context.save()
        
        dismiss()
    }
}
