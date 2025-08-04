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
    
    @Namespace private var animationNamespace
    
    @State private var buttonPressed: [Int: Bool] = [:]
    
    private let animate: Bool
    
    init(selection: Binding<T>, options: [T], displayNames: [String], animate: Bool = true) {
        self._selection = selection
        self.options = options
        self.displayNames = displayNames
        
        self.animate = animate
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
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
                    isPressed: buttonPressed[index, default: false]
                )
                .simultaneousGesture(TapGesture().onEnded {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        buttonPressed[index] = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            buttonPressed[index] = false
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
        .fixedSize(horizontal: false, vertical: true)
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(ColorManager.raisedSurface)
                .animation(.easeInOut(duration: 0.3), value: selection)
        )
    }
}

private struct SegmentButton: View {
    let isSelected: Bool
    let label: String
    let action: () -> Void
    let namespace: Namespace.ID
    let isPressed: Bool

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor)
                        .matchedGeometryEffect(id: "selectedBackground", in: namespace)
                        .scaleEffect(isPressed ? 0.98 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isPressed)
                } else if isPressed {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(ColorManager.secondary.opacity(0.3))
                        .scaleEffect(0.98)
                        .transition(.opacity)
                }

                Text(label)
                    .captionText()
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? ColorManager.text : ColorManager.secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
            }
        }
        .hapticButton(.selection)
        .frame(maxWidth: .infinity)
    }
}
