//
//  HomeSectionHeader.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct HomeSectionHeader<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let trailingContent: Content

    var body: some View {
        HStack(alignment: .center) {
            HStack {
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                
                Spacer()
            }
            .frame(width: 25)

            Text(title.uppercased())
                .headingText(size: 24)

            Spacer()

            trailingContent
        }
        .textColor()
    }
}
