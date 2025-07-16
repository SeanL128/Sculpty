//
//  LabeledButton.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct LabeledButton<Content: View>: View {
    let label: String
    let size: CGFloat
    let action: () -> Void
    let content: Content
    
    init(
        label: String,
        size: CGFloat,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.size = size
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .bodyText(size: size)
                .textColor()
            
            Button {
                action()
            } label: {
               content
            }
            .textColor()
            .animatedButton(scale: 0.98)
        }
    }
}
