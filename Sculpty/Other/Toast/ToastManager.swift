//
//  ToastManager.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/4/25.
//

import SwiftUI

@MainActor
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var toasts: [ToastItem] = []
    
    private init() { }
    
    func show<Content: View>(
        @ViewBuilder content: () -> Content,
        config: ToastConfig = ToastConfig()
    ) {
        let toast = ToastItem(content: content, config: config)
        
        withAnimation(config.animation) {
            toasts.append(toast)
        }
        
        Task {
            try await Task.sleep(nanoseconds: UInt64(config.autoDismissAfter * 1_000_000_000))
            
            NotificationCenter.default.post(name: .dismissToast, object: toast.id)
        }
    }
    
    func dismiss(_ id: UUID) {
        toasts.removeAll { $0.id == id }
    }
    
    func dismissAll() {
        for toast in toasts {
            NotificationCenter.default.post(name: .dismissToast, object: toast.id)
        }
    }
}
