//
//  LogCustomFoodEntryPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/5/25.
//

import SwiftUI
import SwiftData

struct LogCustomFoodEntryPopup: View {
    @Environment(\.modelContext) private var context
    
    @State var log: CaloriesLog
    @State var entry: FoodEntry?
    
    @State var customFood: CustomFood
    
    @Binding var foodAdded: Bool
    
    @State private var servingsInput: String
    @FocusState private var isServingsFocused: Bool
    
    @State private var selectedServingString: String?
    @State private var selectedServing: CustomServing?
    
    private var servingOptions: [CustomServing] { customFood.servingOptions }
    
    private var calories: Double {
        round((selectedServing?.calories ?? 0.0) * (Double(servingsInput) ?? 0.0), 2)
    }
    private var carbs: Double {
        round((selectedServing?.carbs ?? 0.0) * (Double(servingsInput) ?? 0.0), 2)
    }
    private var protein: Double {
        round((selectedServing?.protein ?? 0.0) * (Double(servingsInput) ?? 0.0), 2)
    }
    private var fat: Double {
        round((selectedServing?.fat ?? 0.0) * (Double(servingsInput) ?? 0.0), 2)
    }
    
    private var isValid: Bool { !servingsInput.isEmpty }
    
    init(
        log: CaloriesLog,
        entry: FoodEntry? = nil,
        customFood: CustomFood,
        foodAdded: Binding<Bool> = .constant(false)
    ) {
        self.log = log
        self.entry = entry
        self.customFood = customFood
        self._foodAdded = foodAdded
        
        self.servingsInput = entry != nil ? "\(entry?.servings ?? 1)" : "1"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingL) {
            if servingOptions.isEmpty {
                HStack(alignment: .center) {
                    Spacer()
                    
                    Text("No serving options found")
                        .bodyText()
                        .textColor()
                    
                    Spacer()
                }
                .padding(.vertical, .spacingXS)
            } else {
                VStack(alignment: .leading, spacing: .spacingM) {
                    HStack {
                        Spacer()
                        
                        Text(customFood.name)
                            .subheadingText()
                            .textColor()
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    
                    Input(title: "Servings", text: $servingsInput, isFocused: _isServingsFocused, type: .decimalPad)
                        .onChange(of: servingsInput) {
                            servingsInput = servingsInput.filteredNumeric()
                        }
                    
                    if servingOptions.count > 1 {
                        Button {
                            Popup.show(content: {
                                MenuPopup(
                                    title: "Serving",
                                    options: servingOptions.map { $0.desc },
                                    selection: $selectedServingString
                                )
                            })
                        } label: {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text(selectedServing?.desc ?? "1 serving")
                                    .bodyText()
                                    .textColor()
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .bodyImage()
                                    .secondaryColor()
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, .spacingM)
                            .background(ColorManager.background)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .textColor()
                        .animatedButton()
                        .onChange(of: selectedServingString) {
                            selectedServing = servingOptions.first(where: { $0.desc == selectedServingString })
                        }
                    } else {
                        Text(selectedServing?.desc ?? "1 serving")
                            .bodyText()
                            .textColor()
                    }
                }
                
                VStack(alignment: .leading, spacing: .spacingM) {
                    VStack(spacing: 0) {
                        Divider()
                            .background(ColorManager.text)
                        
                        HStack(alignment: .center) {
                            Text("Calories")
                                .bodyText()
                                .textColor()
                            
                            Spacer()
                            
                            Text("\(calories.formatted())cal")
                                .bodyText()
                                .textColor()
                                .monospacedDigit()
                        }
                        .padding(.spacingXS)
                        
                        Divider()
                            .background(ColorManager.text)
                        
                        HStack(alignment: .center) {
                            Text("Carbs")
                                .bodyText()
                                .textColor()
                            
                            Spacer()
                            
                            Text("\(carbs.formatted())g")
                                .bodyText()
                                .textColor()
                                .monospacedDigit()
                        }
                        .padding(.spacingXS)
                        .background(ColorManager.secondary.opacity(0.1))
                        
                        Divider()
                            .background(ColorManager.text)
                        
                        HStack(alignment: .center) {
                            Text("Protein")
                                .bodyText()
                                .textColor()
                            
                            Spacer()
                            
                            Text("\(protein.formatted())g")
                                .bodyText()
                                .textColor()
                                .monospacedDigit()
                        }
                        .padding(.spacingXS)
                        
                        Divider()
                            .background(ColorManager.text)
                        
                        HStack(alignment: .center) {
                            Text("Fat")
                                .bodyText()
                                .textColor()
                            
                            Spacer()
                            
                            Text("\(fat.formatted())g")
                                .bodyText()
                                .textColor()
                                .monospacedDigit()
                        }
                        .padding(.spacingXS)
                        .background(ColorManager.secondary.opacity(0.1))
                        
                        Divider()
                            .background(ColorManager.text)
                    }
                    .padding(.horizontal, .spacingXS)
                }
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    SaveButton(save: save, isValid: isValid)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            if let servingOption = entry?.customServingOption {
                selectedServingString = servingOption.desc
                selectedServing = servingOption
            } else {
                selectedServingString = servingOptions.first?.desc
                selectedServing = servingOptions.first(where: { $0.desc == selectedServingString })
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
    }
    
    private func save() {
        if let entry = entry {
            entry.fatSecretFood = nil
            entry.customFood = customFood
            entry.servings = Double(servingsInput)
            entry.customServingOption = selectedServing
            entry.name = customFood.name
            entry.calories = calories
            entry.carbs = carbs
            entry.protein = protein
            entry.fat = fat
        } else {
            let entry = FoodEntry(
                caloriesLog: log,
                customFood: customFood,
                servings: Double(servingsInput),
                customServingOption: selectedServing,
                name: customFood.name,
                calories: calories,
                carbs: carbs,
                protein: protein,
                fat: fat
            )
            
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
