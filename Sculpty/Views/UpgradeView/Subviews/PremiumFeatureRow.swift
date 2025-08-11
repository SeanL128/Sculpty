//
//  PremiumFeatureRow.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/7/25.
//

import SwiftUI

struct PremiumFeatureRow: View {
    let image: String
    let title: String
    let text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: .spacingS) {
            Image(systemName: image)
                .subheadingText(weight: .medium)
                .accentColor()
                .frame(width: 30, alignment: .center)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .bodyText()
                    .textColor()
                
                Text(text)
                    .captionText()
                    .secondaryColor()
            }
        }
    }
}
