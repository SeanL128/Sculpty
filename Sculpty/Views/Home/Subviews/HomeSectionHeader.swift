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
        HStack(alignment: .center, spacing: .spacingS) {
            Image(systemName: icon)
                .headingImage()
                .textColor()
                .frame(width: 25, alignment: .center)

            Text(title.uppercased())
                .headingText()
                .textColor()

            Spacer()

            HStack(alignment: .center, spacing: .spacingL) {
                trailingContent
            }
        }
        .padding(.horizontal, .spacingXS)
    }
}
