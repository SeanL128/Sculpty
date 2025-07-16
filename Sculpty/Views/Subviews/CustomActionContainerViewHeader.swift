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
        HStack(alignment: .center) {
            Button {
                onDismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .padding(.trailing, 6)
                    .font(Font.system(size: 22))
            }
            .textColor()
            
            Text(title.uppercased())
                .headingText(size: 32)
                .textColor()
            
            Spacer()
            
            if let trailingItems = trailingItems {
                trailingItems
            }
        }
        .padding(.bottom)
    }
}
