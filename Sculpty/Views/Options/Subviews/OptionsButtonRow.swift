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
            HStack(alignment: .center) {
                Text(title)
                    .bodyText(size: 18)
                
                Image(systemName: "chevron.right")
                    .padding(.leading, -2)
                    .font(Font.system(size: 12))
            }
        }
        .foregroundStyle(isValid ? ColorManager.text : ColorManager.secondary)
        .disabled(!isValid)
        .animatedButton(scale: 0.98, feedback: feedback)
    }
}
