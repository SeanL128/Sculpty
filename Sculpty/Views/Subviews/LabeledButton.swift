//
//  LabeledButton.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct LabeledButton<Content: View>: View {
    let label: String
    let action: () -> Void
    let feedback: SensoryFeedback
    let content: Content
    
    init(
        label: String,
        action: @escaping () -> Void,
        feedback: SensoryFeedback,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.action = action
        self.feedback = feedback
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingXS) {
            Text(label)
                .captionText()
                .textColor()
            
            Button {
                action()
            } label: {
               content
            }
            .textColor()
            .animatedButton(feedback: feedback)
        }
    }
}
