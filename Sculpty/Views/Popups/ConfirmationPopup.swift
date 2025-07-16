//
//  ConfirmationPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/27/25.
//

import SwiftUI

struct ConfirmationPopup: View {
    @Binding private var selection: Bool
    private var promptText: String
    private var resultText: String?
    private var cancelText: String
    private var confirmText: String
    
    init(
        selection: Binding<Bool>,
        promptText: String = "Are you sure?",
        resultText: String? = nil,
        cancelText: String = "Cancel",
        confirmText: String = "Confirm"
    ) {
        self._selection = selection
        self.promptText = promptText
        self.resultText = resultText
        self.cancelText = cancelText
        self.confirmText = confirmText
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(alignment: .center, spacing: 6) {
                Text(promptText)
                    .bodyText(size: 16)
                    .multilineTextAlignment(.center)
                
                if let resultText {
                    Text(resultText)
                        .bodyText(size: 14)
                        .multilineTextAlignment(.center)
                }
            }
            
            HStack(spacing: 24) {
                Button {
                    selection = false
                    
                    Popup.dismissLast()
                } label: {
                    Text(cancelText)
                        .bodyText(size: 18)
                }
                .textColor()
                .animatedButton()
                
                Divider()
                    .frame(width: 1, height: 24)
                    .background(ColorManager.text)
                
                Button {
                    selection = true
                    
                    Popup.dismissLast()
                } label: {
                    Text(confirmText)
                        .bodyText(size: 18, weight: .bold)
                }
                .textColor()
                .animatedButton(feedback: .impact(weight: .medium))
            }
        }
    }
}
