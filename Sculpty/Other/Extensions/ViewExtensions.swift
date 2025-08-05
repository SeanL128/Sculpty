//
//  ViewExtensions.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/25/25.
//

import SwiftUI

extension View {
    // Edge Swipe
    func disableEdgeSwipe() -> some View {
        self
            .onAppear {
                EdgeSwipeManager.shared.disable()
            }
            .onDisappear {
                EdgeSwipeManager.shared.enable()
            }
    }
    
    func disableEdgeSwipe(_ disabled: Bool) -> some View {
        self
            .onAppear {
                if disabled {
                    EdgeSwipeManager.shared.disable()
                } else {
                    EdgeSwipeManager.shared.enable()
                }
            }
            .onDisappear {
                EdgeSwipeManager.shared.enable()
            }
            .onChange(of: disabled) {
                if disabled {
                    EdgeSwipeManager.shared.disable()
                } else {
                    EdgeSwipeManager.shared.enable()
                }
            }
    }
    
    // Button Styles
    func animatedButton(
        scale: Double = 0.95,
        feedback: SensoryFeedback = .impact(weight: .light),
        isValid: Bool = true
    ) -> some View {
        self.buttonStyle(AnimatedButtonStyle(scale: scale, feedback: feedback, isValid: isValid))
    }
    
    func hapticButton(_ feedback: SensoryFeedback, isValid: Bool = true) -> some View {
        self.animatedButton(scale: 1, feedback: feedback, isValid: isValid)
    }
    
    func borderedToFilledButton(
        scale: Double = 0.97,
        feedback: SensoryFeedback = .impact(weight: .light),
        isValid: Bool = true
    ) -> some View {
        self.buttonStyle(BorderedToFilledButtonStyle(scale: scale, feedback: feedback, isValid: isValid))
    }
    
    func filledToBorderedButton(
        color: Color = ColorManager.text,
        scale: Double = 0.97,
        feedback: SensoryFeedback = .impact(weight: .light),
        isValid: Bool = true
    ) -> some View {
        self.buttonStyle(FilledToBorderedButtonStyle(color: color, scale: scale, feedback: feedback, isValid: isValid))
    }
    
    // Limit Text
    func limitText(_ text: Binding<String>, to characterLimit: Int) -> some View {
        self
            .onChange(of: text.wrappedValue) {
                text.wrappedValue = String(text.wrappedValue.prefix(characterLimit))
            }
    }
    
    // Blinking
    func blinking(_ min: Double = 0.3, _ max: Double = 0.7) -> some View {
        self.modifier(BlinkViewModifier(min: min, max: max))
    }
    
    // Haptics
    func hapticFeedback(_ feedback: SensoryFeedback, trigger: Int) -> some View {
        self.sensoryFeedback(feedback, trigger: trigger) { _, _ in
            CloudSettings.shared.enableHaptics
        }
    }
    
    // Card
    func card() -> some View {
        self
            .padding(.vertical, .spacingM)
            .padding(.horizontal, 20)
            .background(ColorManager.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorManager.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // Colors
    func textColor() -> some View {
        self.foregroundStyle(ColorManager.text)
    }
    
    func secondaryColor() -> some View {
        self.foregroundStyle(ColorManager.secondary)
    }
    
    func accentColor() -> some View {
        self.foregroundStyle(ColorManager.accent)
    }
    
    func backgroundColor() -> some View {
        self.background(ColorManager.background)
    }
    
    // Fonts
    func pageTitleText(weight: Font.Weight = .bold) -> some View {
        self
            .font(.system(size: 32, weight: weight))
    }
    
    func headingText(weight: Font.Weight = .bold) -> some View {
        self.font(.system(size: 24, weight: weight))
    }
    
    func subheadingText(weight: Font.Weight = .bold) -> some View {
        self.font(.system(size: 18, weight: weight))
    }
    
    func bodyText(weight: Font.Weight = .medium) -> some View {
        self.font(.system(size: 16, weight: weight))
    }
    
    func secondaryText(weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: 14, weight: weight))
    }
    
    func captionText(weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: 12, weight: weight))
    }
    
    func pageTitleImage(weight: Font.Weight = .medium) -> some View {
        self.font(.system(size: 22, weight: weight))
    }
    
    func headingImage(weight: Font.Weight = .medium) -> some View {
        self.font(.system(size: 16, weight: weight))
    }
    
    func subheadingImage(weight: Font.Weight = .medium) -> some View {
        self.font(.system(size: 10, weight: weight))
    }
    
    func bodyImage(weight: Font.Weight = .medium) -> some View {
        self.font(.system(size: 8, weight: weight))
    }
    
    func secondaryImage(weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: 8, weight: weight))
    }
    
    func captionImage(weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: 6, weight: weight))
    }
}
