//
//  EmptyState.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct EmptyState: View {
    let image: String
    let text: String
    let subtext: String
    
    var topPadding: CGFloat = .spacingXL
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingL) {
            if !image.isEmpty {
                Image(systemName: image)
                    .font(.system(size: 96, weight: .medium))
                    .textColor()
            }
            
            if !text.isEmpty || !subtext.isEmpty {
                VStack(alignment: .center, spacing: .spacingXS) {
                    if !text.isEmpty {
                        Text(text)
                            .bodyText()
                            .textColor()
                    }
                    
                    if !subtext.isEmpty {
                        Text(subtext)
                            .secondaryText()
                            .secondaryColor()
                    }
                }
            }
        }
        .padding(.top, topPadding)
        .frame(maxWidth: .infinity)
        .transition(.scale.combined(with: .opacity))
    }
}
