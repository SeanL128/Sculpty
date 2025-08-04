//
//  SearchFood.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/1/25.
//

import SwiftUI

struct SearchFood: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var api: FatSecretAPI = FatSecretAPI()
    
    @State var log: CaloriesLog
    @State private var foodAdded: Bool = false
    
    @State private var searchInput = ""
    @FocusState private var isSearchFocused: Bool
    
    @State private var searchTask: Task<Void, Never>?
    @State private var searchResults: [FatSecretFood] = []
    
    @State private var error: Bool = false
    
    @State private var foodToAdd: FatSecretFood?
    @State private var foodsToAdd: [FatSecretFood] = []
    
    @State private var looping: Bool = false
    
    private var image: String {
        if error {
            return "exclamationmark.triangle"
        } else {
            if searchResults.isEmpty {
                return "magnifyingglass"
            } else {
                return ""
            }
        }
    }
    
    private var text: String {
        if error {
            return "Error searching"
        } else {
            if searchResults.isEmpty {
                if api.isLoading {
                    return "Loading..."
                } else if api.loaded {
                    return "No results"
                } else {
                    return "Search for a food to begin"
                }
            } else {
                return "Didn't find what you're looking for?"
            }
        }
    }
    
    var body: some View {
        ContainerView(title: "Search Food", spacing: .spacingL, lazy: true, trailingItems: {
            NavigationLink {
                BarcodeScanner(log: log, foodAdded: $foodAdded, foodToAdd: $foodToAdd, foodsToAdd: $foodsToAdd)
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "barcode.viewfinder")
                        .pageTitleImage()
                }
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
            
            if !searchResults.isEmpty {
                VStack(alignment: .leading, spacing: .listSpacing) {
                    ForEach(searchResults, id: \.food_id) { food in
                        Button {
                            Popup.show(content: {
                                LogFoodEntryPopup(log: log, food: food, foodAdded: $foodAdded)
                            })
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
                VStack(alignment: .center, spacing: .spacingL) {
                    if !image.isEmpty {
                        Image(systemName: image)
                            .font(.system(size: 96, weight: .medium))
                            .textColor()
                    }
                    
                    VStack(alignment: .center, spacing: .spacingXS) {
                        Text(text)
                            .bodyText()
                            .textColor()
                        
                        Button {
                            Popup.show(content: {
                                AddFoodEntryPopup(log: log, foodAdded: $foodAdded)
                            })
                        } label: {
                            HStack(alignment: .center, spacing: .spacingXS) {
                                Text("Add Custom Entry")
                                    .secondaryText()
                                
                                Image(systemName: "chevron.right")
                                    .secondaryImage()
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
                
                FatSecretLink()
            }
            .frame(maxWidth: .infinity)
        }
        .onChange(of: foodAdded) {
            if foodAdded && foodsToAdd.isEmpty {
                dismiss()
            }
        }
        .onChange(of: foodToAdd) {
            if let food = foodToAdd {
                Popup.show(content: {
                    LogFoodEntryPopup(log: log, food: food, foodAdded: $foodAdded)
                })
                
                foodToAdd = nil
            }
        }
        .onChange(of: foodsToAdd) {
            if !foodsToAdd.isEmpty {
                Task {
                    for food in foodsToAdd {
                        await Popup.showAndWait(content: {
                            LogFoodEntryPopup(log: log, food: food, foodAdded: $foodAdded)
                        })
                    }
                    
                    foodsToAdd = []
                    
                    dismiss()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: searchResults.count)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: text)
    }
    
    private func searchFoods() {
        searchTask?.cancel()
            
        searchTask = Task {
            guard searchInput.count >= 2 else {
                searchResults = []
                return
            }
            
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            guard !Task.isCancelled else { return }
            
            error = false
            api.isLoading = true
            api.loaded = false
            
            do {
                searchResults = try await api.searchFoods(searchInput)
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
}
