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
        
    @Query(filter: #Predicate<CustomFood> { !$0.hidden }) private var foods: [CustomFood]
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    @Binding var foodToAdd: CustomFood?
    
    private var filteredFoods: [CustomFood] {
        if searchText.isEmpty {
            return foods
        } else {
            return foods.filter { food in
                food.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
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
                        CustomFoodListRow(food: food, foodToAdd: $foodToAdd)
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
    }
}
