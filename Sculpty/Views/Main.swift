//
//  Main.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/19/25.
//

import SwiftUI

struct Main: View {
    @EnvironmentObject private var settings: CloudSettings
    
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
        }
        .onChange(of: settings.onboarded) { oldValue, newValue in
            withAnimation(.easeOut(duration: 0.5)) { }
        }
    }
}

#Preview {
    Main()
}
