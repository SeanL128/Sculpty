//
//  UsageIndicator.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/7/25.
//

import SwiftUI

struct UsageIndicator: View {
    let title: String
    let used: Int
    let total: Int
    
    private var progress: Double {
        Double(used) / Double(total)
    }
    
    private var isAtLimit: Bool {
        used >= total
    }
    
    private var isNearLimit: Bool {
        used >= Int(Double(total) * 0.9)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingXS) {
            Text(title)
                .captionText()
                .secondaryColor()
            
            VStack(alignment: .center, spacing: .spacingS) {
                Text("\(used)/\(total)")
                    .bodyText(weight: .semibold)
                    .foregroundColor(isAtLimit ? ColorManager.destructive : isNearLimit ? ColorManager.warning : ColorManager.text) // swiftlint:disable:this line_length
                
                ProgressView(value: progress)
                    .frame(height: 6)
                    .frame(width: 100)
                    .progressViewStyle(.linear)
                    .accentColor(isAtLimit ? ColorManager.destructive : isNearLimit ? ColorManager.warning : ColorManager.text) // swiftlint:disable:this line_length
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
    }
}
