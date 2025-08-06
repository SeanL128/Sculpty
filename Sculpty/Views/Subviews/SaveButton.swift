//
//  SaveButton.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct SaveButton: View {
    let save: () -> Void
    let isValid: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingM) {
            Spacer()
                .frame(height: 0)
            
            Button {
                if isValid {
                    save()
                }
            } label: {
                Text("Save")
                    .bodyText()
                    .padding(.vertical, 12)
                    .padding(.horizontal, .spacingL)
            }
            .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
            .background(isValid ? ColorManager.accent : ColorManager.secondary.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(!isValid)
            .animatedButton(feedback: .success, isValid: isValid)
            .animation(.easeInOut(duration: 0.2), value: isValid)
        }
    }
}
