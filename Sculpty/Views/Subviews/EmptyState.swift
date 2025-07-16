//
//  EmptyState.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct EmptyState: View {
    let message: String
    let size: CGFloat
    
    var body: some View {
        Text(message)
            .bodyText(size: size)
            .textColor()
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.8)),
                removal: .opacity.combined(with: .scale(scale: 0.8))
            ))
    }
}
