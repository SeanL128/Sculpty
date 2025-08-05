//
//  Popup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/19/25.
//

import SwiftUI

struct Popup {
    @MainActor
    static func show<Content: View>(
        @ViewBuilder content: () -> Content,
        config: PopupConfig = PopupConfig(),
        onDismiss: (() -> Void)? = nil
    ) {
        PopupManager.shared.show(content: content, config: config, onDismiss: onDismiss)
    }
    
    @MainActor
    static func showAndWait<Content: View>(
        @ViewBuilder content: () -> Content,
        config: PopupConfig = PopupConfig()
    ) async {
        await withCheckedContinuation { continuation in
            show(content: content, config: config) {
                continuation.resume()
            }
        }
    }
    
    @MainActor
    static func dismissLast() {
        PopupManager.shared.dismissLast()
    }
    
    @MainActor
    static func dismissAll() {
        PopupManager.shared.dismissAll()
    }
}
