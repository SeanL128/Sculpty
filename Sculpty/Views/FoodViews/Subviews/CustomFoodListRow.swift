//
//  CustomFoodListRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/6/25.
//

import SwiftUI

struct CustomFoodListRow: View {
    let food: CustomFood
    
    @Binding var foodToAdd: CustomFood?
    
    var body: some View {
        HStack(alignment: .center) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    foodToAdd = food
                }
            } label: {
                HStack(alignment: .center, spacing: .spacingXS) {
                    Text(food.name)
                        .bodyText(weight: foodToAdd == food ? .bold : .regular)
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "chevron.right")
                        .bodyImage(weight: foodToAdd == food ? .bold : .medium)
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
    }
}
