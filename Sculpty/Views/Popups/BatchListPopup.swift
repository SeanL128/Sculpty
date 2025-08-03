//
//  BatchListPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/15/25.
//

import SwiftUI

struct BatchListPopup: View {
    @State private var items: [FatSecretFood]
    private let onRemove: (Int) -> Void
    
    @State private var height: CGFloat = 0
    
    init (items: [FatSecretFood], onRemove: @escaping (Int) -> Void) {
        self.items = items
        self.onRemove = onRemove
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingL) {
            VStack(alignment: .center, spacing: .spacingM) {
                Text("Scanned Items")
                    .subheadingText()
                    .multilineTextAlignment(.center)
                
                ScrollView {
                    LazyVStack(spacing: .listSpacing) {
                        if items.isEmpty {
                            EmptyState(
                                image: "fork.knife",
                                text: "No items scanned",
                                subtext: "Scan a food barcode to add it",
                                topPadding: 0
                            )
                        } else {
                            ForEach(Array(items.enumerated()), id: \.element.food_id) { index, food in
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(alignment: .center) {
                                        Text(food.food_name)
                                            .bodyText()
                                            .textColor()
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        
                                        Spacer()
                                        
                                        Button {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                items.remove(at: index)
                                                
                                                onRemove(index)
                                            }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .bodyText()
                                        }
                                        .textColor()
                                        .animatedButton(feedback: .impact(weight: .medium))
                                    }
                                    
                                    if let brand = food.brand_name {
                                        Text(brand)
                                            .captionText()
                                            .secondaryColor()
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .background(GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    height = geo.size.height
                                }
                            }
                            .onChange(of: geo.size.height) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    height = geo.size.height
                                }
                            }
                    })
                }
                .frame(maxHeight: min(height, 300))
                .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
            }
            
            VStack(alignment: .center, spacing: .spacingM) {
                Spacer()
                    .frame(height: 0)
                
                Button {
                    Popup.dismissLast()
                } label: {
                    Text("OK")
                        .bodyText()
                        .padding(.vertical, 12)
                        .padding(.horizontal, .spacingL)
                }
                .textColor()
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .animatedButton()
            }
        }
    }
}
