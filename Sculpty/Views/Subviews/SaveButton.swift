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
    let size: CGFloat
    
    var body: some View {
        Button {
            if isValid {
                save()
            }
        } label: {
            Text("Save")
                .bodyText(size: size, weight: .bold)
        }
        .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
        .disabled(!isValid)
        .animatedButton(feedback: .success, isValid: isValid)
        .animation(.easeInOut(duration: 0.2), value: isValid)
    }
}
