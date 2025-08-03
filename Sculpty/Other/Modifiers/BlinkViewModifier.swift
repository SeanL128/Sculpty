//
//  BlinkViewModifier.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/25/25.
//

import SwiftUI

struct BlinkViewModifier: ViewModifier {
    let min: Double
    let max: Double
    @State private var blinking: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(blinking ? min : max)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    blinking = true
                }
            }
    }
}
