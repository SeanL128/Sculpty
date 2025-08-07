//
//  SearchFood.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/1/25.
//

import SwiftUI
import SwiftData

struct SearchFood: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var api: FatSecretAPI = FatSecretAPI()
    
    @State var log: CaloriesLog
    @State private var foodAdded: Bool = false
    
    @State private var recentFatSecretFoods: [FatSecretFood] = []
    @State private var recentCustomFoods: [CustomFood] = []
    @State private var recentFoodsLoaded: Bool = false
    
    @State private var searchInput = ""
    @FocusState private var isSearchFocused: Bool
    
    @State private var searchTask: Task<Void, Never>?
    @State private var fatSecretResults: [FatSecretFood] = []
    @State private var customFoodResults: [CustomFood] = []
    
    @State private var error: Bool = false
    
    @State private var customFoodToAdd: CustomFood?
    
    @State private var fatSecretFoodToAdd: FatSecretFood?
    @State private var fatSecretFoodsToAdd: [FatSecretFood] = []
    
    @State private var looping: Bool = false
    
    private var hasResults: Bool {
        !fatSecretResults.isEmpty || !customFoodResults.isEmpty
    }
    
    private var image: String {
        if error {
            return "exclamationmark.triangle"
        } else if hasResults {
            return ""
        } else {
            return "magnifyingglass"
        }
    }
    
    private var text: String {
        if error {
            return "Error searching"
        } else if hasResults {
            return "Didn't find what you're looking for?"
        } else if api.isLoading {
            return "Loading..."
        } else if api.loaded {
            return "No results"
        } else {
            return "Search for a food to begin"
        }
    }
    
    var body: some View {
        ContainerView(title: "Search Food", spacing: .spacingL, lazy: true, trailingItems: {
            NavigationLink {
                CustomFoodList(foodToAdd: $customFoodToAdd)
            } label: {
                Image(systemName: "list.bullet")
                    .pageTitleImage()
            }
            .textColor()
            .animatedButton()
            
            NavigationLink {
                BarcodeScanner(
                    log: log,
                    foodAdded: $foodAdded,
                    foodToAdd: $fatSecretFoodToAdd,
                    foodsToAdd: $fatSecretFoodsToAdd
                )
            } label: {
                Image(systemName: "barcode.viewfinder")
                    .pageTitleImage()
            }
            .textColor()
            .animatedButton()
        }) {
            TextField("Search Foods", text: $searchInput)
                .focused($isSearchFocused)
                .textFieldStyle(
                    UnderlinedTextFieldStyle(
                        isFocused: Binding<Bool>(
                            get: { isSearchFocused },
                            set: { isSearchFocused = $0 }
                        ),
                        text: $searchInput
                    )
                )
                .padding(.bottom, .spacingXS)
                .onChange(of: searchInput) { searchFoods() }
            
            if hasResults {
                VStack(alignment: .leading, spacing: .listSpacing) {
                    ForEach(customFoodResults, id: \.id) { food in
                        Button {
                            customFoodToAdd = food
                        } label: {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text(food.name)
                                    .bodyText(weight: .regular)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                                Image(systemName: "chevron.right")
                                    .bodyImage()
                            }
                        }
                        .textColor()
                        .hapticButton(.selection)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                    }
                    
                    ForEach(fatSecretResults, id: \.food_id) { food in
                        Button {
                            fatSecretFoodToAdd = food
                        } label: {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text("\(food.food_name)\(food.brand_name == nil ? "" : " (\(food.brand_name ?? ""))")")
                                    .bodyText(weight: .regular)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                                Image(systemName: "chevron.right")
                                    .bodyImage()
                            }
                        }
                        .textColor()
                        .hapticButton(.selection)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                    }
                }
            }
            
            VStack(alignment: .center, spacing: .spacingXXL) {
                if recentFoodsLoaded {
                    VStack(alignment: .center, spacing: .spacingL) {
                        if !image.isEmpty {
                            Image(systemName: image)
                                .font(.system(size: 96, weight: .medium))
                                .textColor()
                        }
                        
                        VStack(alignment: .center, spacing: .spacingS) {
                            Text(text)
                                .bodyText(weight: .bold)
                                .textColor()
                            
                            NavigationLink {
                                AddCustomFood(foodToAdd: $customFoodToAdd)
                            } label: {
                                HStack(alignment: .center, spacing: .spacingXS) {
                                    Text("Add Custom Food")
                                        .bodyText(weight: .regular)
                                    
                                    Image(systemName: "chevron.right")
                                        .bodyImage()
                                }
                            }
                            .textColor()
                            .animatedButton()
                            
                            Button {
                                Popup.show(content: {
                                    AddFoodEntryPopup(log: log, foodAdded: $foodAdded)
                                })
                            } label: {
                                HStack(alignment: .center, spacing: .spacingXS) {
                                    Text("Add One-Time Entry")
                                        .bodyText(weight: .regular)
                                    
                                    Image(systemName: "chevron.right")
                                        .bodyImage()
                                }
                            }
                            .textColor()
                            .animatedButton(feedback: .selection)
                        }
                    }
                    .padding(.top, .spacingXL)
                    .frame(maxWidth: .infinity)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: text)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: image)
                } else {
                    Spacer()
                        .frame(height: 0)
                }
                
                FatSecretLink()
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            do {
                let fatSecretFoods = try context.fetch(FetchDescriptor<FoodEntry>())
                    .filter { $0.type == .fatSecret }
                    .sorted { $0.date > $1.date }
                    .compactMap { $0.fatSecretFood }
                    .prefix(15)
                
                for food in fatSecretFoods where !recentFatSecretFoods.contains(where: { $0.food_id == food.food_id }) {
                    recentFatSecretFoods.append(food)
                }
                
                let customFoods = try context.fetch(FetchDescriptor<FoodEntry>())
                    .filter { $0.type == .custom && $0.customFood?.hidden == false }
                    .sorted { $0.date > $1.date }
                    .compactMap { $0.customFood }
                    .prefix(15)
                
                for food in customFoods where !recentCustomFoods.contains(where: { $0.id == food.id }) {
                    recentCustomFoods.append(food)
                }
            } catch {
                debugLog("Error: \(error.localizedDescription)")
            }
            
            if !hasResults {
                customFoodResults = recentCustomFoods
                fatSecretResults = recentFatSecretFoods
            }
            
            recentFoodsLoaded = true
        }
        .onChange(of: foodAdded) {
            if foodAdded && fatSecretFoodsToAdd.isEmpty {
                dismiss()
            }
        }
        .onChange(of: fatSecretFoodToAdd) {
            if let food = fatSecretFoodToAdd {
                Popup.show(content: {
                    LogFatSecretFoodEntryPopup(log: log, food: food, foodAdded: $foodAdded)
                })
                
                fatSecretFoodToAdd = nil
            }
        }
        .onChange(of: customFoodToAdd) {
            if let customFood = customFoodToAdd {
                Popup.show(content: {
                    LogCustomFoodEntryPopup(log: log, customFood: customFood, foodAdded: $foodAdded)
                })
                
                customFoodToAdd = nil
            }
        }
        .onChange(of: fatSecretFoodsToAdd) {
            if !fatSecretFoodsToAdd.isEmpty {
                Task {
                    for food in fatSecretFoodsToAdd {
                        await Popup.showAndWait(content: {
                            LogFatSecretFoodEntryPopup(log: log, food: food, foodAdded: $foodAdded)
                        })
                    }
                    
                    fatSecretFoodsToAdd = []
                    
                    dismiss()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: hasResults)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: text)
    }
    
    private func searchFoods() {
        searchTask?.cancel()
            
        searchTask = Task {
            let length = searchInput.count
            
            guard searchInput.count >= 2 else {
                if !hasResults || length == 0 {
                    customFoodResults = recentCustomFoods
                    fatSecretResults = recentFatSecretFoods
                }
                
                return
            }
            
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            guard !Task.isCancelled else { return }
            
            error = false
            api.isLoading = true
            api.loaded = false
            
            async let customResults = searchCustomFoods(searchInput)
            async let fatSecretResults = api.searchFoods(searchInput)
            
            do {
                let (custom, fatSecret) = try await (customResults, fatSecretResults)
                
                self.customFoodResults = custom
                self.fatSecretResults = fatSecret
            } catch {
                debugLog("Search error: \(error.localizedDescription)")
                
                if error.localizedDescription != "cancelled" {
                    self.error = true
                }
            }
            
            api.isLoading = false
            api.loaded = true
        }
    }
    
    private func searchCustomFoods(_ query: String) async -> [CustomFood] {
        return await MainActor.run {
            let descriptor = FetchDescriptor<CustomFood>(
                predicate: #Predicate<CustomFood> { customFood in
                    !customFood.hidden &&
                    customFood.name.localizedStandardContains(query)
                },
                sortBy: [SortDescriptor(\.name)]
            )
            
            do {
                return try context.fetch(descriptor)
            } catch {
                debugLog("Error searching custom foods: \(error.localizedDescription)")
                return []
            }
        }
    }
}
