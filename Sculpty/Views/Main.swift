//
//  Main.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/19/25.
//

import SwiftUI

struct Main: View {
    @EnvironmentObject private var settings: CloudSettings
    @StateObject private var popupManager = PopupManager.shared
    
    var body: some View {
        ZStack {
            if !settings.onboarded {
                Onboarding()
                    .transition(
                        .asymmetric(
                            insertion: .identity,
                            removal: .opacity.combined(with: .scale(scale: 2))
                        )
                    )
                    .zIndex(1)
            }
            
            Home()
                .opacity(settings.onboarded ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: settings.onboarded)
            
            ForEach(Array(popupManager.popups.enumerated()), id: \.element.id) { index, popup in
                PopupOverlay(
                    popup: popup,
                    isLast: index == popupManager.popups.count - 1,
                    onDismiss: {
                        popupManager.dismiss(popup.id)
                    }
                )
                .zIndex(Double(index + 1000))
            }
        }
        .onChange(of: settings.onboarded) {
            withAnimation(.easeOut(duration: 0.5)) { }
        }
    }
}
