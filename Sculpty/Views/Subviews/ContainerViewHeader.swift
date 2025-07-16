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
        HStack(alignment: .center) {
            if showBackButton {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .padding(.trailing, 6)
                        .font(Font.system(size: 22))
                }
                .textColor()
            }
            
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
