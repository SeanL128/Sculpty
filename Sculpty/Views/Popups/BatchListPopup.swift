//
//  BatchListPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/15/25.
//

import SwiftUI

struct BatchListPopup: View {
    let items: [FatSecretFood]
    let onRemove: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Text("Scanned Items")
                .bodyText(size: 18, weight: .bold)
                .multilineTextAlignment(.center)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(items.enumerated()), id: \.element.food_id) { index, food in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(food.food_name)
                                    .bodyText(size: 16)
                                    .textColor()
                                    .lineLimit(1)
                                
                                if let brand = food.brand_name {
                                    Text(brand)
                                        .bodyText(size: 12)
                                        .secondaryColor()
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    onRemove(index)
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .padding(.horizontal, 8)
                                    .font(Font.system(size: 16))
                            }
                            .textColor()
                            .animatedButton(feedback: .impact(weight: .medium))
                        }
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: items.count)
            }
            .frame(maxHeight: 300)
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            
            Button {
                Popup.dismissLast()
            } label: {
                Text("OK")
                    .bodyText(size: 18, weight: .bold)
            }
            .textColor()
            .animatedButton()
        }
    }
}
