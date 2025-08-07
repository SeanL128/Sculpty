//
//  SmallToggleStyle.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/29/25.
//

import SwiftUI

struct SmallToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: .spacingXS) {
            configuration.label
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    configuration.isOn.toggle()
                }
            } label: {
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .stroke(ColorManager.border, lineWidth: 2)
                    .frame(width: 45, height: 25)
                    .background(configuration.isOn ? ColorManager.accent : ColorManager.background)
                    .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                    .overlay(alignment: .center) {
                        Circle()
                            .frame(width: 19, height: 19)
                            .foregroundStyle(ColorManager.text)
                            .offset(x: configuration.isOn ? 9 : -9)
                    }
            }
            .hapticButton(.selection)
        }
    }
}
