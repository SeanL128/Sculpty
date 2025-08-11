//
//  TypedSegmentedControl.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/27/25.
//

import SwiftUI

struct TypedSegmentedControl<T: Hashable>: View {
    @Binding var selection: T
    let options: [T]
    let displayNames: [String]
    let minPremiumIndex: Int
    
    @StateObject private var storeManager: StoreKitManager = StoreKitManager.shared
    
    @Namespace private var animationNamespace
    private let animate: Bool
    
    @State private var buttonPressed: [Int: Bool] = [:]
    
    @State private var width: CGFloat = 0
    @State private var height: CGFloat = 0
    
    init(
        selection: Binding<T>,
        options: [T],
        displayNames: [String],
        animate: Bool = true,
        minPremiumIndex: Int? = nil
    ) {
        self._selection = selection
        self.options = options
        self.displayNames = displayNames
        
        self.animate = animate
        
        self.minPremiumIndex = minPremiumIndex ?? options.count
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                let isValid: Bool = storeManager.hasPremiumAccess || index < minPremiumIndex
                
                HStack(alignment: .center, spacing: 0) {
                    SegmentButton(
                        isSelected: selection == option,
                        label: displayNames[index],
                        action: {
                            if selection != option {
                                if animate {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                        selection = option
                                    }
                                } else {
                                    selection = option
                                }
                            }
                        },
                        namespace: animationNamespace,
                        isPressed: buttonPressed[index, default: false],
                        isValid: isValid
                    )
                    .simultaneousGesture(TapGesture().onEnded {
                        if isValid {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                buttonPressed[index] = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    buttonPressed[index] = false
                                }
                            }
                        }
                    })
                    
                    if index < options.count - 1 {
                        let currentSelected = selection == option
                        let nextSelected = selection == options[index + 1]
                        let shouldShowDivider = !currentSelected && !nextSelected
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(ColorManager.border.opacity(0.7))
                            .frame(width: 1)
                            .padding(.vertical, 6)
                            .opacity(shouldShowDivider ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.2), value: shouldShowDivider)
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(2)
        .background(GeometryReader { geo in
            RoundedRectangle(cornerRadius: 6)
                .fill(ColorManager.raisedSurface)
                .animation(.easeInOut(duration: 0.3), value: selection)
                .onAppear {
                    width = storeManager.hasPremiumAccess ? 0 : geo.size.width * CGFloat(Double(options.count - minPremiumIndex) / Double(options.count)) // swiftlint:disable:this line_length
                    
                    height = geo.size.height
                }
                .onChange(of: geo.size) {
                    width = storeManager.hasPremiumAccess ? 0 : geo.size.width * CGFloat(Double(options.count - minPremiumIndex) / Double(options.count)) // swiftlint:disable:this line_length
                    
                    height = geo.size.height
                }
        })
        .overlay(alignment: .trailing) {
            if !storeManager.hasPremiumAccess, minPremiumIndex < options.count {
                NavigationLink {
                    UpgradeView()
                } label: {
                    Image(systemName: "crown.fill")
                        .secondaryText()
                        .accentColor()
                        .frame(width: width, height: height, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.black)
                                .opacity(0.6)
                                .padding(0.1)
                                .blur(radius: 1.0)
                        )
                }
                .hapticButton(.selection, isValid: !storeManager.hasPremiumAccess)
                .transition(.opacity)
            }
        }
    }
}
