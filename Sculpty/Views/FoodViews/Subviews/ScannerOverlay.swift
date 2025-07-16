//
//  ScannerOverlay.swift
//  Sculpty
//
//  Created by Sean Lindsay on 7/15/25.
//

import SwiftUI

struct ScannerOverlay: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let scanAreaWidth: CGFloat = min(geometry.size.width * 0.8, 300)
            let scanAreaHeight: CGFloat = scanAreaWidth * 0.6
            let cornerRadius: CGFloat = 12
            
            // Background
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: scanAreaWidth, height: scanAreaHeight)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            
            // Corners
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 23, height: 3)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 3, height: 23)
                            .offset(y: -3)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 23, height: 3)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 3, height: 23)
                            .offset(y: -3)
                    }
                }
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 3, height: 23)
                            .offset(y: 3)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 23, height: 3)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 3, height: 23)
                            .offset(y: 3)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 23, height: 3)
                    }
                }
            }
            .frame(width: scanAreaWidth, height: scanAreaHeight)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            // Scanning Line
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            ColorManager.text.dark.opacity(0.6),
                            ColorManager.text.dark.opacity(0.9),
                            ColorManager.text.dark.opacity(0.6),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: scanAreaWidth - 60, height: 2)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .offset(y: animationOffset)
                .onAppear {
                    animationOffset = (-scanAreaHeight / 2) + 30
                    
                    withAnimation(
                        .easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        animationOffset = (scanAreaHeight / 2) - 30
                    }
                }
        }
    }
}
