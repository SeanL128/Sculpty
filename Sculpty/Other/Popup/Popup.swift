//
//  Popup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/19/25.
//

import SwiftUI

struct Popup {
    @MainActor
    static func show<Content: View>(@ViewBuilder content: () -> Content, config: PopupConfig = PopupConfig(), onDismiss: (() -> Void)? = nil) {
        PopupManager.shared.show(content: content, config: config, onDismiss: onDismiss)
    }
    
    @MainActor
    static func dismissLast() {
        PopupManager.shared.dismissLast()
    }
    
    @MainActor
    static func dismissAll() {
        PopupManager.shared.dismissAll()
    }
    
    @MainActor
    static func showAndWait<Content: View>(@ViewBuilder content: () -> Content, config: PopupConfig = PopupConfig()) async {
        await withCheckedContinuation { continuation in
            show(content: content, config: config) {
                continuation.resume()
            }
        }
    }
    
    @MainActor
    static func showTopAndWait<Content: View>(@ViewBuilder content: () -> Content, config: PopupConfig = PopupConfig()) async {
        var topConfig = config
        topConfig.position = .top
        await showAndWait(content: content, config: topConfig)
    }
    
    @MainActor
    static func showCenterAndWait<Content: View>(@ViewBuilder content: () -> Content, config: PopupConfig = PopupConfig()) async {
        var centerConfig = config
        centerConfig.position = .center
        await showAndWait(content: content, config: centerConfig)
    }
    
    @MainActor
    static func showBottomAndWait<Content: View>(@ViewBuilder content: () -> Content, config: PopupConfig = PopupConfig()) async {
        var bottomConfig = config
        bottomConfig.position = .bottom
        await showAndWait(content: content, config: bottomConfig)
    }
    
    @MainActor
    static func showTop<Content: View>(@ViewBuilder content: () -> Content, config: PopupConfig = PopupConfig(), onDismiss: (() -> Void)? = nil) {
        var topConfig = config
        topConfig.position = .top
        show(content: content, config: topConfig, onDismiss: onDismiss)
    }
    
    @MainActor
    static func showCenter<Content: View>(@ViewBuilder content: () -> Content, config: PopupConfig = PopupConfig(), onDismiss: (() -> Void)? = nil) {
        var centerConfig = config
        centerConfig.position = .center
        show(content: content, config: centerConfig, onDismiss: onDismiss)
    }
    
    @MainActor
    static func showBottom<Content: View>(@ViewBuilder content: () -> Content, config: PopupConfig = PopupConfig(), onDismiss: (() -> Void)? = nil) {
        var bottomConfig = config
        bottomConfig.position = .bottom
        show(content: content, config: bottomConfig, onDismiss: onDismiss)
    }
    
    @MainActor
    static func toast(_ message: String, duration: TimeInterval = 3.0) {
        var config = PopupConfig()
        config.position = .bottom
        config.autoDismissAfter = duration
        config.horizontalPadding = 20
        config.verticalPadding = 50
        config.tapOutsideToDismiss = false
        config.dragToDismiss = true
        config.backgroundColor = Color.clear
        config.animation = .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.2)
        
        show(content: {
            HStack {
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.85))
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
        }, config: config)
    }
    
    @MainActor
    static func alert(title: String, message: String, primaryButton: String = "OK", secondaryButton: String? = nil, onPrimary: @escaping () -> Void = {}, onSecondary: @escaping () -> Void = {}) {
        var config = PopupConfig()
        config.position = .center
        config.tapOutsideToDismiss = false
        config.dragToDismiss = false
        config.animation = .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.2)
        
        show(content: {
            VStack(spacing: 16) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.secondary)
                
                HStack(spacing: 12) {
                    if let secondaryButton = secondaryButton {
                        Button(secondaryButton) {
                            dismissLast()
                            onSecondary()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button(primaryButton) {
                        dismissLast()
                        onPrimary()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
        }, config: config)
    }
    
    @MainActor
    static func alertAndWait(title: String, message: String, primaryButton: String = "OK", secondaryButton: String? = nil) async -> Bool {
        await withCheckedContinuation { continuation in
            alert(
                title: title,
                message: message,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton,
                onPrimary: {
                    continuation.resume(returning: true)
                },
                onSecondary: {
                    continuation.resume(returning: false)
                }
            )
        }
    }
}
