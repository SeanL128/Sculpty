//
//  Main.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/19/25.
//

import SwiftUI

struct Main: View {
    @AppStorage(UserKeys.onboarded.rawValue) private var onboarded = false
    
    var body: some View {
        ZStack {
            if !onboarded {
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
                .opacity(onboarded ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: onboarded)
        }
        .onChange(of: onboarded) { oldValue, newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.5)) { }
            }
        }
    }
}

#Preview {
    Main()
}
