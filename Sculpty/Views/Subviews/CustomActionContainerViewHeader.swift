//
//  CustomActionContainerViewHeader.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct CustomActionContainerViewHeader<TrailingItems: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    let trailingItems: TrailingItems?
    let onDismiss: () -> Void
    
    init(
        title: String,
        onDismiss: @escaping () -> Void
    ) where TrailingItems == EmptyView {
        self.title = title
        self.onDismiss = onDismiss
        trailingItems = nil
    }
    
    init(
        title: String,
        onDismiss: @escaping () -> Void,
        @ViewBuilder trailingItems: () -> TrailingItems
    ) {
        self.title = title
        self.onDismiss = onDismiss
        self.trailingItems = trailingItems()
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                onDismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .pageTitleImage()
            }
            .textColor()
            
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
        .padding(.bottom, .spacingXS)
    }
}
