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
        HStack(alignment: .center) {
            HStack(alignment: .center) {
                Spacer()
                
                Image(systemName: image)
                    .font(Font.system(size: 18))
                
                Spacer()
            }
            .frame(width: 25)
            
            Text(title.uppercased())
                .headingText(size: 24)
            
            Spacer()
        }
        .textColor()
        .transition(.asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    }
}
