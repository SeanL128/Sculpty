//
//  ToastOverlay.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/4/25.
//

import SwiftUI

struct ToastOverlay: View {
    let toast: ToastItem
    let onDismiss: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .center, spacing: .spacingM) {
            Spacer()
            
            VStack {
                toast.content
                    .padding(.horizontal, toast.config.horizontalPadding)
                    .padding(.vertical, toast.config.verticalPadding)
            }
            .background(
                Capsule()
                    .stroke(toast.config.toastBorderColor)
                    .fill(toast.config.toastBackgroundColor)
            )
            .offset(y: dragOffset.height + (isVisible ? 0 : 200))
            .opacity(isVisible ? 1.0 : 0.0)
            .onTapGesture {
                if toast.config.tapToDismiss {
                    withAnimation(toast.config.animation) {
                        isVisible = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onDismiss()
                    }
                }
            }
            
            Spacer()
                .frame(height: 0)
        }
        .padding(.horizontal, .spacingL)
        .onAppear {
            withAnimation(toast.config.animation) {
                isVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissToast)) { notification in
            if let toastId = notification.object as? UUID, toastId == toast.id {
                withAnimation(toast.config.animation) {
                    isVisible = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onDismiss()
                }
            }
        }
    }
}
