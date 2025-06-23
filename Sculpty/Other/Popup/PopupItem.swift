//
//  PopupItem.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/19/25.
//

import SwiftUI

struct PopupItem: Identifiable {
    let id = UUID()
    let content: AnyView
    let config: PopupConfig
    let onDismiss: (() -> Void)?
    
    init<Content: View>(@ViewBuilder content: () -> Content, config: PopupConfig = PopupConfig(), onDismiss: (() -> Void)? = nil) {
        self.content = AnyView(content())
        self.config = config
        self.onDismiss = onDismiss
    }
}
