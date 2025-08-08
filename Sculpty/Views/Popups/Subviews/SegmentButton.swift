//
//  SegmentButton.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/8/25.
//

import SwiftUI

struct SegmentButton: View {
    let isSelected: Bool
    let label: String
    let action: () -> Void
    let namespace: Namespace.ID
    let isPressed: Bool
    var isValid: Bool = true

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
        .disabled(!isValid)
        .hapticButton(.selection, isValid: isValid)
        .frame(maxWidth: .infinity)
    }
}
