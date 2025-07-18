//
//  LogFoodEntryPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/28/25.
//

import SwiftUI
import SwiftData

struct LogFoodEntryPopup: View {
    @Environment(\.modelContext) private var context
    
    @StateObject private var api: FatSecretAPI = FatSecretAPI()
    
    @State var log: CaloriesLog
    @State var entry: FoodEntry?
    
    @State var food: FatSecretFood
    
    @Binding var foodAdded: Bool
    
    @State private var servingsInput: String
    @FocusState private var isServingsFocused: Bool
    
    @State private var selectedServingString: String?
    @State private var selectedServing: Serving?
    @State var servingOptions: [Serving] = []
    
    private var calories: Double {
        round((Double(selectedServing?.calories ?? "0") ?? 0.0) * (Double(servingsInput) ?? 0.0), 2)
    }
    private var carbs: Double {
        round((Double(selectedServing?.carbohydrate ?? "0") ?? 0.0) * (Double(servingsInput) ?? 0.0), 2)
    }
    private var protein: Double {
        round((Double(selectedServing?.protein ?? "0") ?? 0.0) * (Double(servingsInput) ?? 0.0), 2)
    }
    private var fat: Double {
        round((Double(selectedServing?.fat ?? "0") ?? 0.0) * (Double(servingsInput) ?? 0.0), 2)
    }
    
    private var isValid: Bool { !servingsInput.isEmpty }
    
    init (log: CaloriesLog, entry: FoodEntry? = nil, food: FatSecretFood, foodAdded: Binding<Bool> = .constant(false)) {
        self.log = log
        self.entry = entry
        self.food = food
        self._foodAdded = foodAdded
        
        self.servingsInput = entry != nil ? "\(entry?.servings ?? 1)" : "1"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if servingOptions.isEmpty {
                HStack(alignment: .center) {
                    Spacer()
                    
                    Text("Loading...")
                        .bodyText(size: 18)
                        .textColor()
                    
                    Spacer()
                }
                .padding(.vertical)
            } else {
                HStack {
                    Spacer()
                    
                    Text(formatFoodName(food))
                        .bodyText(size: 18, weight: .bold)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                
                Input(title: "Servings", text: $servingsInput, isFocused: _isServingsFocused, type: .decimalPad)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .onChange(of: servingsInput) {
                        servingsInput = servingsInput.filteredNumeric()
                    }
                
                if servingOptions.count > 1 {
                    Button {
                        Popup.show(content: {
                            MenuPopup(
                                title: "Serving",
                                options: servingOptions.compactMap { $0.fullServingDescription },
                                selection: $selectedServingString
                            )
                        })
                    } label: {
                        HStack(alignment: .center) {
                            Text(selectedServing?.fullServingDescription ?? "1 serving")
                                .bodyText(size: 18, weight: .bold)
                                .multilineTextAlignment(.leading)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(Font.system(size: 12, weight: .bold))
                        }
                    }
                    .textColor()
                    .padding(.horizontal)
                    .onChange(of: selectedServingString) {
                        selectedServing = servingOptions.first(where: { $0.fullServingDescription == selectedServingString }) // swiftlint:disable:this line_length
                    }
                    .animatedButton()
                } else {
                    Text(selectedServing?.fullServingDescription ?? "1 serving")
                        .bodyText(size: 18, weight: .bold)
                        .textColor()
                        .padding(.horizontal)
                }
                
                Spacer()
                    .frame(height: 0)
                
                VStack(spacing: 1) {
                    Divider()
                        .background(ColorManager.text)
                    
                    HStack(alignment: .center) {
                        Text("Calories")
                            .bodyText(size: 16)
                            .textColor()
                        
                        Spacer()
                        
                        Text("\(calories.formatted())cal")
                            .bodyText(size: 16, weight: .bold)
                            .textColor()
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: calories)
                    }
                    .padding(1)
                    
                    Divider()
                        .background(ColorManager.text)
                    
                    HStack(alignment: .center) {
                        Text("Carbs")
                            .bodyText(size: 16)
                            .textColor()
                        
                        Spacer()
                        
                        Text("\(carbs.formatted())g")
                            .bodyText(size: 16, weight: .bold)
                            .textColor()
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: carbs)
                    }
                    .padding(1)
                    .background(ColorManager.secondary.opacity(0.1))
                    
                    Divider()
                        .background(ColorManager.text)
                    
                    HStack(alignment: .center) {
                        Text("Protein")
                            .bodyText(size: 16)
                            .textColor()
                        
                        Spacer()
                        
                        Text("\(protein.formatted())g")
                            .bodyText(size: 16, weight: .bold)
                            .textColor()
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: protein)
                    }
                    .padding(1)
                    
                    Divider()
                        .background(ColorManager.text)
                    
                    HStack(alignment: .center) {
                        Text("Fat")
                            .bodyText(size: 16)
                            .textColor()
                        
                        Spacer()
                        
                        Text("\(fat.formatted())g")
                            .bodyText(size: 16, weight: .bold)
                            .textColor()
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: fat)
                    }
                    .padding(1)
                    .background(ColorManager.secondary.opacity(0.1))
                    
                    Divider()
                        .background(ColorManager.text)
                }
                .padding(.horizontal)
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    SaveButton(save: save, isValid: isValid, size: 18)
                    
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 12)
                
                FatSecretLink()
            }
        }
        .onAppear {
            Task {
                api.isLoading = true
                api.loaded = false
                
                do {
                    servingOptions = try await api.getServingOptions(for: food)
                    
                    if let servingOption = entry?.servingOption {
                        selectedServingString = servingOption.fullServingDescription
                        selectedServing = servingOption
                    } else {
                        selectedServingString = servingOptions.first?.fullServingDescription
                        selectedServing = servingOptions.first(where: { $0.fullServingDescription == selectedServingString }) // swiftlint:disable:this line_length
                    }
                } catch {
                    debugLog("Error: \(error.localizedDescription)")
                }
                
                api.isLoading = false
                api.loaded = true
            }
        }
        .animation(.easeInOut(duration: 0.2), value: servingOptions.isEmpty)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
    }
    
    private func save() {
        if let entry = entry {
            entry.servings = Double(servingsInput)
            entry.servingOption = selectedServing
            
            entry.calories = calories
            entry.carbs = carbs
            entry.protein = protein
            entry.fat = fat
        } else {
            let entry = FoodEntry(
                caloriesLog: log,
                fatSecretFood: food,
                servings: Double(servingsInput),
                servingOption: selectedServing,
                name: formatFoodName(food),
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
        } catch {
            debugLog("Error: \(error.localizedDescription)")
        }
        
        foodAdded = true
        
        Popup.dismissLast()
    }

    private func formatFoodName(_ food: FatSecretFood) -> String {
        if let brandName = food.brand_name {
            return "\(food.food_name) (\(brandName))"
        } else {
            return food.food_name
        }
    }
}
