//
//  ReorderControls.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct ReorderControls: View {
    let moveUp: () -> Void
    let moveDown: () -> Void
    
    let canMoveUp: Bool
    let canMoveDown: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingS) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    moveUp()
                }
            } label: {
                Image(systemName: "chevron.up")
                    .secondaryText(weight: .medium)
            }
            .foregroundStyle(canMoveUp ? ColorManager.text : ColorManager.secondary)
            .disabled(!canMoveUp)
            .animatedButton(feedback: .selection)
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    moveDown()
                }
            } label: {
                Image(systemName: "chevron.down")
                    .secondaryText(weight: .medium)
            }
            .foregroundStyle(canMoveDown ? ColorManager.text : ColorManager.secondary)
            .disabled(!canMoveDown)
            .animatedButton(feedback: .selection)
        }
    }
}
