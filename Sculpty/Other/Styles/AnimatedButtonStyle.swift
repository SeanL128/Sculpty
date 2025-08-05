//
//  AnimatedButtonStyle.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/15/25.
//

import SwiftUI

struct AnimatedButtonStyle: ButtonStyle {
    let scale: Double
    let feedback: SensoryFeedback
    let isValid: Bool
    
    @State private var triggerCount: Int = 0
    @State private var isManuallyPressed: Bool = false
    
    init(scale: Double = 0.98, feedback: SensoryFeedback = .impact(weight: .light), isValid: Bool = true) {
        self.feedback = feedback
        self.scale = scale
        self.isValid = isValid
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isValid && (configuration.isPressed || isManuallyPressed) ? scale : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed || isManuallyPressed)
            .hapticFeedback(feedback, trigger: triggerCount)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if isValid && !isManuallyPressed {
                            isManuallyPressed = true
                            
                            triggerCount += 1
                        }
                    }
                    .onEnded { _ in
                        isManuallyPressed = false
                    }
            )
    }
}
