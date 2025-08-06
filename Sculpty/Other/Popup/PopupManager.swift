//
//  PopupManager.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/19/25.
//

import SwiftUI

@MainActor
class PopupManager: ObservableObject {
    static let shared = PopupManager()
    
    @Published var popups: [PopupItem] = []
    
    private init() { }
    
    func show<Content: View>(
        @ViewBuilder content: () -> Content,
        config: PopupConfig = PopupConfig(),
        onDismiss: (() -> Void)? = nil
    ) {
        let popup = PopupItem(content: content, config: config, onDismiss: onDismiss)
        
        dismissKeyboard()
        
        withAnimation(config.animation) {
            popups.append(popup)
        }
        
        if let dismissAfter = config.autoDismissAfter {
            Task {
                try await Task.sleep(nanoseconds: UInt64(dismissAfter * 1_000_000_000))
                
                NotificationCenter.default.post(name: .dismissPopup, object: popup.id)
            }
        }
    }
    
    func dismiss(_ id: UUID) {
        guard let popup = popups.first(where: { $0.id == id }) else { return }
        
        dismissKeyboard()
        
        popup.onDismiss?()
        
        popups.removeAll { $0.id == id }
    }
    
    func dismissLast() {
        guard let last = popups.last else { return }
        
        NotificationCenter.default.post(name: .dismissPopup, object: last.id)
    }
    
    func dismissAll() {
        for popup in popups {
            NotificationCenter.default.post(name: .dismissPopup, object: popup.id)
        }
    }
}
