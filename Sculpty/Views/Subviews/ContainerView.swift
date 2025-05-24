//
//  ContainerView.swift
//  Sculpty
//
//  Created by Sean Lindsay on 4/28/25.
//

import SwiftUI

struct ContainerView<Content: View, TrailingItems: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    let content: Content
    var title: String
    
    var spacing: CGFloat
    
    let trailingItems: TrailingItems?
    
    var backgroundColor: Color
    
    var showNavBar: Bool
    var showBackButton: Bool
    var showScrollBar: Bool
    
    let onDismiss: (() -> Void)?
    
    init(
        title: String,
        spacing: CGFloat = 12,
        backgroundColor: Color = ColorManager.background,
        showNavBar: Bool = false,
        showBackButton: Bool = true,
        showScrollBar: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) where TrailingItems == EmptyView {
        self.title = title
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.showNavBar = showNavBar
        self.showBackButton = showBackButton
        self.showScrollBar = showScrollBar
        self.onDismiss = onDismiss
        self.content = content()
        trailingItems = nil
    }
    
    init(
        title: String,
        spacing: CGFloat = 12,
        backgroundColor: Color = ColorManager.background,
        showNavBar: Bool = false,
        showBackButton: Bool = true,
        showScrollBar: Bool = false,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder trailingItems: () -> TrailingItems,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.showNavBar = showNavBar
        self.showBackButton = showBackButton
        self.showScrollBar = showScrollBar
        self.onDismiss = onDismiss
        self.trailingItems = trailingItems()
        self.content = content()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        if showBackButton {
                            Button {
                                if let onDismiss = onDismiss {
                                    onDismiss()
                                }
                                
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
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: spacing) {
                            content
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
                    .scrollIndicators(showScrollBar ? .visible : .hidden)
                    .scrollContentBackground(.hidden)
                }
                .padding()
            }
            .toolbar(showNavBar ? .visible : .hidden, for: .navigationBar)
        }
    }
}
