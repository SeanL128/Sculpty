//
//  OptionsButtonRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsButtonRow: View {
    let title: String
    let isValid: Bool
    
    let action: () -> Void
    
    let feedback: SensoryFeedback
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(alignment: .center, spacing: .spacingXS) {
                Text(title)
                    .bodyText()
                
                Image(systemName: "chevron.right")
                    .bodyImage()
            }
        }
        .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
        .disabled(!isValid)
        .animatedButton(feedback: feedback)
    }
}
