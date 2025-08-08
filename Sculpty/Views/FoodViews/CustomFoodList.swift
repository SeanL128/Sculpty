//
//  CustomFoodList.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/6/25.
//

import SwiftUI
import SwiftData

struct CustomFoodList: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var storeManager: StoreKitManager = StoreKitManager.shared
        
    @Query(filter: #Predicate<CustomFood> { !$0.hidden }) private var foods: [CustomFood]
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    @Binding var foodToAdd: CustomFood?
    
    private var filteredFoods: [CustomFood] {
        return foods.search(searchText, by: \.name)
    }
    
    var body: some View {
        if storeManager.hasPremiumAccess {
            ContainerView(title: "Custom Foods", spacing: .spacingL, lazy: true, trailingItems: {
                NavigationLink {
                    AddCustomFood()
                } label: {
                    Image(systemName: "plus")
                        .pageTitleImage()
                }
                .textColor()
                .animatedButton()
            }) {
                TextField("Search Foods", text: $searchText)
                    .focused($isSearchFocused)
                    .textFieldStyle(
                        UnderlinedTextFieldStyle(
                            isFocused: Binding<Bool>(
                                get: { isSearchFocused },
                                set: { isSearchFocused = $0 }
                            ),
                            text: $searchText)
                    )
                    .padding(.bottom, .spacingXS)
                
                if filteredFoods.isEmpty {
                    EmptyState(
                        image: "magnifyingglass",
                        text: "No foods found",
                        subtext: "Try adjusting your search"
                    )
                } else {
                    VStack(alignment: .leading, spacing: .listSpacing) {
                        ForEach(filteredFoods, id: \.id) { food in
                            HStack(alignment: .center) {
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        foodToAdd = food
                                    }
                                    
                                    dismiss()
                                } label: {
                                    HStack(alignment: .center, spacing: .spacingXS) {
                                        Text(food.name)
                                            .bodyText(weight: .regular)
                                            .multilineTextAlignment(.leading)
                                        
                                        Image(systemName: "chevron.right")
                                            .bodyImage(weight: .medium)
                                    }
                                }
                                .textColor()
                                .animatedButton(feedback: .selection)
                                
                                Spacer()
                                
                                NavigationLink {
                                    AddCustomFood(food: food)
                                } label: {
                                    Image(systemName: "pencil")
                                        .bodyText(weight: .regular)
                                }
                                .animatedButton()
                            }
                            .textColor()
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .leading)),
                                removal: .opacity.combined(with: .move(edge: .trailing))
                            ))
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: filteredFoods)
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: searchText)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: filteredFoods.isEmpty)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    KeyboardDoneButton()
                }
            }
        } else {
            EmptyView()
                .onAppear {
                    dismiss()
                }
        }
    }
}
