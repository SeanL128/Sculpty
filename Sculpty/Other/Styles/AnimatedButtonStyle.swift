//
//  AnimatedButtonStyle.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/15/25.
//

import SwiftUI

struct AnimatedButtonStyle: ButtonStyle {
    let scale: Double
    let feedback: SensoryFeedback?
    let isValid: Bool
    
    @State private var triggerCount: Int = 0
    
    init(scale: Double = 0.95, feedback: SensoryFeedback? = nil, isValid: Bool = true) {
        self.feedback = feedback
        self.scale = scale
        self.isValid = isValid
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isValid && configuration.isPressed ? scale : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .sensoryFeedback(feedback ?? .selection, trigger: triggerCount)
            .onChange(of: configuration.isPressed) {
                if isValid, configuration.isPressed, feedback != nil {
                    triggerCount += 1
                }
            }
    }
}
