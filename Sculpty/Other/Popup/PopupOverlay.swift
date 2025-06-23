//
//  PopupOverlay.swift
//  Sculpty
//
//  Created by Sean Lindsay on 6/19/25.
//

import SwiftUI

struct PopupOverlay: View {
    let popup: PopupItem
    let isLast: Bool
    let onDismiss: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            popup.config.backgroundColor
                .ignoresSafeArea()
                .opacity(backgroundOpacity)
                .onTapGesture {
                    if popup.config.tapOutsideToDismiss {
                        dismissWithAnimation()
                    }
                }
            
            popupContent
        }
        .onAppear {
            withAnimation(popup.config.animation) {
                isVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissPopup)) { notification in
            if let popupId = notification.object as? UUID, popupId == popup.id {
                dismissWithAnimation()
            }
        }
    }
    
    private var backgroundOpacity: Double {
        if !isVisible {
            return 0.0
        }
        
        if !isLast {
            return 0.1
        }
        
        if isDragging {
            let dragDistance = abs(dragOffset.height)
            let maxDrag: CGFloat = 200
            return max(0.3, 1.0 - Double(dragDistance / maxDrag))
        }
        
        return 1.0
    }
    
    private func dismissWithAnimation() {
        withAnimation(popup.config.animation) {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onDismiss()
        }
    }
    
    @ViewBuilder
    private var popupContent: some View {
        VStack {
            if [.bottom, .center].contains(popup.config.position) {
                Spacer()
            }
            
            VStack {
                popup.content
                    .padding(.horizontal, popup.config.horizontalPadding)
                    .padding(.vertical, popup.config.verticalPadding)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: popup.config.cornerRadius)
                    .fill(popup.config.popupBackgroundColor)
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: 15) // Outer shadow
            .offset(y: dragOffset.height + animationOffset)
            .scaleEffect(isVisible ? (isDragging ? 0.98 : 1.0) : 0.9)
            .opacity(isVisible ? 1.0 : 0.0)
            .gesture(
                popup.config.dragToDismiss ? dragGesture : nil
            )
            
            if [.top, .center].contains(popup.config.position) {
                Spacer()
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var animationOffset: CGFloat {
        if isVisible {
            return 0
        }
        
        switch popup.config.position {
        case .top:
            return -200
        case .center:
            return 0
        case .bottom:
            return 200
        }
    }
    
    private var offsetForPosition: CGFloat {
        switch popup.config.position {
        case .top:
            return -200
        case .center:
            return 0
        case .bottom:
            return 200
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                    isDragging = true
                }
                
                switch popup.config.position {
                case .top:
                    dragOffset.height = min(0, value.translation.height)
                case .bottom:
                    dragOffset.height = max(0, value.translation.height)
                case .center:
                    dragOffset = value.translation
                }
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isDragging = false
                }
                
                let dismissThreshold: CGFloat = 100
                let velocity = value.predictedEndLocation.y - value.location.y
                let shouldDismiss = abs(value.translation.height) > dismissThreshold || abs(velocity) > 500
                
                if shouldDismiss {
                    dismissWithAnimation()
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        dragOffset = .zero
                    }
                }
            }
    }
}
