//
//  CustomActionContainerView.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/6/25.
//

import SwiftUI

struct CustomActionContainerView<Content: View, TrailingItems: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    let content: Content
    let title: String
    
    let spacing: CGFloat
    
    let trailingItems: TrailingItems?
    
    let backgroundColor: Color
    
    let showNavBar: Bool
    let showScrollBar: Bool
    
    let lazy: Bool
    
    let onDismiss: () -> Void
    
    init(
        title: String,
        spacing: CGFloat = 12,
        backgroundColor: Color = ColorManager.background,
        showNavBar: Bool = false,
        showScrollBar: Bool = false,
        lazy: Bool = false,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) where TrailingItems == EmptyView {
        self.title = title
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.showNavBar = showNavBar
        self.showScrollBar = showScrollBar
        self.lazy = lazy
        self.onDismiss = onDismiss
        self.content = content()
        trailingItems = nil
    }
    
    init(
        title: String,
        spacing: CGFloat = 12,
        backgroundColor: Color = ColorManager.background,
        showNavBar: Bool = false,
        showScrollBar: Bool = false,
        lazy: Bool = false,
        onDismiss: @escaping () -> Void,
        @ViewBuilder trailingItems: () -> TrailingItems,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.showNavBar = showNavBar
        self.showScrollBar = showScrollBar
        self.lazy = lazy
        self.onDismiss = onDismiss
        self.trailingItems = trailingItems()
        self.content = content()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea(edges: .all)
                
                VStack(alignment: .leading) {
                    if !title.isEmpty {
                        CustomActionContainerViewHeader(
                            title: title,
                            onDismiss: onDismiss,
                            trailingItems: { trailingItems }
                        )
                    }
                    
                    ScrollView {
                        if lazy {
                            LazyVStack(alignment: .leading, spacing: spacing) {
                                content
                            }
                        } else {
                            VStack(alignment: .leading, spacing: spacing) {
                                content
                            }
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
