//
//  ConfirmationPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/27/25.
//

import SwiftUI

struct ConfirmationPopup: View {
    @Binding private var selection: Bool
    private let promptText: String
    private let resultText: String?
    private let cancelText: String
    private let cancelColor: Color
    private let confirmText: String
    private let confirmColor: Color
    
    init(
        selection: Binding<Bool>,
        promptText: String = "Are you sure?",
        resultText: String? = nil,
        cancelText: String = "Cancel",
        cancelColor: Color = ColorManager.text,
        confirmText: String = "Confirm",
        confirmColor: Color = ColorManager.destructive
    ) {
        self._selection = selection
        self.promptText = promptText
        self.resultText = resultText
        self.cancelText = cancelText
        self.cancelColor = cancelColor
        self.confirmText = confirmText
        self.confirmColor = confirmColor
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingL) {
            VStack(alignment: .center, spacing: .spacingXS) {
                Text(promptText)
                    .textColor()
                    .subheadingText()
                    .multilineTextAlignment(.center)
                
                if let resultText {
                    Text(resultText)
                        .secondaryColor()
                        .secondaryText()
                        .multilineTextAlignment(.center)
                }
            }
            
            HStack(alignment: .center, spacing: .spacingM) {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selection = false
                    }
                    
                    Popup.dismissLast()
                } label: {
                    Text(cancelText)
                        .bodyText()
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .foregroundStyle(cancelColor)
                .animatedButton()
                
                Divider()
                    .frame(width: 1, height: 24)
                    .background(ColorManager.border)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selection = true
                    }
                    
                    Popup.dismissLast()
                } label: {
                    Text(confirmText)
                        .bodyText(weight: .bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .foregroundStyle(confirmColor)
                .animatedButton(feedback: .impact(weight: .medium))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
