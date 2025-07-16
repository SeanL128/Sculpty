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
        VStack(alignment: .center, spacing: 10) {
            Button {
                moveUp()
            } label: {
                Image(systemName: "chevron.up")
                    .font(Font.system(size: 14))
            }
            .foregroundStyle(canMoveUp ? ColorManager.text : ColorManager.secondary)
            .disabled(!canMoveUp)
            
            Button {
                moveDown()
            } label: {
                Image(systemName: "chevron.down")
                    .font(Font.system(size: 14))
            }
            .foregroundStyle(canMoveDown ? ColorManager.text : ColorManager.secondary)
            .disabled(!canMoveDown)
        }
    }
}
