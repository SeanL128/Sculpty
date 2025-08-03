//
//  MacroLabel.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct MacroLabel: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        Text("\(value)g \(label)")
            .foregroundStyle(color)
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.3), value: value)
    }
}
