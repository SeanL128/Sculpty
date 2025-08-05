//
//  ToastItem.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/4/25.
//

import SwiftUI

struct ToastItem: Identifiable {
    let id = UUID()
    let content: AnyView
    let config: ToastConfig
    
    init<Content: View>(
        @ViewBuilder content: () -> Content,
        config: ToastConfig = ToastConfig()
    ) {
        self.content = AnyView(content())
        self.config = config
    }
}
