//
//  OptionsSectionHeader.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/9/25.
//

import SwiftUI

struct OptionsSectionHeader: View {
    let title: String
    let image: String
    
    var body: some View {
        HStack(alignment: .center, spacing: .spacingS) {
            Image(systemName: image)
                .headingImage()
                .textColor()
                .frame(width: 25, alignment: .center)
            
            Text(title.uppercased())
                .headingText()
                .textColor()
            
            Spacer()
        }
        .transition(.asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    }
}
