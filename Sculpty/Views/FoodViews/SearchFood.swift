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
        ContainerView(title: "Search Food", spacing: 16, showScrollBar: true, lazy: true, trailingItems: {
            NavigationLink {
                BarcodeScannerView(log: log, foodAdded: $foodAdded, foodToAdd: $foodToAdd, foodsToAdd: $foodsToAdd)
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "barcode.viewfinder")
                        .padding(.horizontal, 5)
                        .font(Font.system(size: 20))
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
                .padding(.bottom, 5)
                .onChange(of: searchInput) { searchFoods() }
            
            if !searchResults.isEmpty {
                ForEach(searchResults, id: \.food_id) { food in
                    Button {
                        Popup.show(content: {
                            LogFoodEntryPopup(log: log, food: food, foodAdded: $foodAdded)
                        })
                    } label: {
                        HStack(alignment: .center) {
                            Text("\(food.food_name)\(food.brand_name == nil ? "" : " (\(food.brand_name ?? ""))")")
                                .bodyText(size: 16)
                                .multilineTextAlignment(.leading)
                            
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 10))
                        }
                    }
                    .textColor()
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                }
                
                Spacer()
                    .frame(height: 16)
            }
            
            HStack(alignment: .center) {
                Spacer()
                
                VStack(alignment: .center, spacing: 12) {
                    Text(text)
                        .bodyText(size: searchResults.isEmpty ? 18 : 16)
                        .textColor()
                    
                    Button {
                        Popup.show(content: {
                            AddFoodEntryPopup(log: log, foodAdded: $foodAdded)
                        })
                    } label: {
                        HStack(alignment: .center) {
                            Text("Add Custom Entry")
                                .bodyText(size: 14, weight: .bold)
                            
                            Image(systemName: "chevron.right")
                                .padding(.leading, -2)
                                .font(Font.system(size: 8, weight: .bold))
                        }
                    }
                    .textColor()
                }
                
                Spacer()
            }
            
            Spacer()
                .frame(height: 16)
            
            FatSecretLink()
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
        .animation(.easeInOut(duration: 0.3), value: text)
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
