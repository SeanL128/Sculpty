//
//  LaunchScreen.swift
//  Sculpty
//
//  Created by Sean Lindsay on 8/2/25.
//

import SwiftUI

struct LaunchScreen: View {
    @State private var animationCompleted = false
    @State private var fadeOut = false
    
    let onAnimationComplete: () -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
            ColorManager.background
                .ignoresSafeArea(edges: .all)
            
            LottieView(
                animationName: "sculpty_launch_animation",
                onAnimationComplete: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                        fadeOut = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        onAnimationComplete()
                    }
                }
            )
            .frame(width: 300, height: 300)
        }
        .opacity(fadeOut ? 0 : 1)
        .onAppear {
            animationCompleted = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if !fadeOut {
                    withAnimation(.easeOut(duration: 0.4)) {
                        fadeOut = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        onAnimationComplete()
                    }
                }
            }
        }
    }
}
