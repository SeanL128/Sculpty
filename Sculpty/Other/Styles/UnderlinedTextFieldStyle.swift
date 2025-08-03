//
//  UnderlinedTextFieldStyle.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/15/25.
//

import SwiftUI

struct UnderlinedTextFieldStyle: TextFieldStyle {
    var isFocused: Binding<Bool>?
    var text: Binding<String>?
    
    var normalLineColor: Color = ColorManager.secondary
    var focusedLineColor: Color = ColorManager.text
    var normalLineHeight: CGFloat = 1
    var focusedLineHeight: CGFloat = 1.5
    var animationDuration: Double = 0.175
    var emptyBackgroundColor: Color = .clear
    
    init() {
        isFocused = nil
        text = nil
    }
    
    init(isFocused: Binding<Bool>) {
        self.isFocused = isFocused
        text = nil
    }
    
    init(
        isFocused: Binding<Bool>,
        normalLineColor: Color = ColorManager.secondary,
        focusedLineColor: Color = ColorManager.text,
        normalLineHeight: CGFloat = 1,
        focusedLineHeight: CGFloat = 1.5,
        animationDuration: Double = 0.175
    ) {
        self.isFocused = isFocused
        text = nil
        self.normalLineColor = normalLineColor
        self.focusedLineColor = focusedLineColor
        self.normalLineHeight = normalLineHeight
        self.focusedLineHeight = focusedLineHeight
        self.animationDuration = animationDuration
    }
    
    init(
        isFocused: Binding<Bool>,
        text: Binding<String>,
        normalLineColor: Color = ColorManager.secondary,
        focusedLineColor: Color = ColorManager.text,
        normalLineHeight: CGFloat = 1,
        focusedLineHeight: CGFloat = 1.5,
        animationDuration: Double = 0.175,
        emptyBackgroundColor: Color = ColorManager.secondary
    ) {
        self.isFocused = isFocused
        self.text = text
        self.normalLineColor = normalLineColor
        self.focusedLineColor = focusedLineColor
        self.normalLineHeight = normalLineHeight
        self.focusedLineHeight = focusedLineHeight
        self.animationDuration = animationDuration
        self.emptyBackgroundColor = emptyBackgroundColor
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            configuration
            
            Group {
                if let focusBinding = isFocused {
                    Rectangle()
                        .fill(focusBinding.wrappedValue ? focusedLineColor : normalLineColor)
                        .frame(height: focusBinding.wrappedValue ? focusedLineHeight : normalLineHeight)
                        .padding(.top, 2.25)
                        .scaleEffect(x: focusBinding.wrappedValue ? 1.005 : 1, anchor: .center)
                        .animation(.easeOut(duration: animationDuration), value: focusBinding.wrappedValue)
                } else {
                    Rectangle()
                        .fill(normalLineColor)
                        .frame(height: normalLineHeight)
                        .padding(.top, 2)
                }
            }
        }
        .contentShape(.rect)
    }
}
