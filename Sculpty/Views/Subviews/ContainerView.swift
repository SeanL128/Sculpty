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
    
    init(
        title: String,
        spacing: CGFloat = 12,
        backgroundColor: Color = ColorManager.background,
        showNavBar: Bool = false,
        showBackButton: Bool = true,
        @ViewBuilder content: () -> Content
    ) where TrailingItems == EmptyView {
        self.title = title
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.showNavBar = showNavBar
        self.showBackButton = showBackButton
        self.content = content()
        self.trailingItems = nil
    }
    
    init(
        title: String,
        spacing: CGFloat = 12,
        backgroundColor: Color = ColorManager.background,
        showNavBar: Bool = false,
        showBackButton: Bool = true,
        @ViewBuilder trailingItems: () -> TrailingItems,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.spacing = spacing
        self.backgroundColor = backgroundColor
        self.showNavBar = showNavBar
        self.showBackButton = showBackButton
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
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title3)
                                    .textColor()
                            }
                            .padding(.trailing, 6)
                        }
                        
                        Text(title.uppercased())
                            .headingText()
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
                    .scrollIndicators(.hidden)
                    .scrollContentBackground(.hidden)
                }
                .padding()
            }
            .toolbar(showNavBar ? .visible : .hidden, for: .navigationBar)
        }
    }
}
