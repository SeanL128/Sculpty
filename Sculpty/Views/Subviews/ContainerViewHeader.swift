//
//  ContainerViewHeader.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct ContainerViewHeader<TrailingItems: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    let showBackButton: Bool
    let trailingItems: TrailingItems?
    
    init(
        title: String,
        showBackButton: Bool = true
    ) where TrailingItems == EmptyView {
        self.title = title
        self.showBackButton = showBackButton
        trailingItems = nil
    }
    
    init(
        title: String,
        showBackButton: Bool = true,
        @ViewBuilder trailingItems: () -> TrailingItems
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.trailingItems = trailingItems()
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if showBackButton {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .pageTitleImage()
                }
                .textColor()
            }
            
            Text(title.uppercased())
                .pageTitleText()
                .textColor()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            if let trailingItems = trailingItems {
                HStack(alignment: .center, spacing: .spacingL) {
                    trailingItems
                }
            }
        }
        .padding(.bottom, .spacingS)
    }
}
