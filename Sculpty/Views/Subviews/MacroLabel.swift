//
//  MacroLabel.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct MacroLabel: View {
    let value: Double
    let label: String
    let size: CGFloat
    let color: Color
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(value.formatted())g")
                .statsText(size: size)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: value)
            
            Text(" \(label)")
                .bodyText(size: size)
        }
        .foregroundStyle(color)
    }
}
