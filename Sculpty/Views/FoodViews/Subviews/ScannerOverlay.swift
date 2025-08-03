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
        GeometryReader { geo in
            let scanAreaWidth: CGFloat = min(geo.size.width * 0.8, 300)
            let scanAreaHeight: CGFloat = scanAreaWidth * 0.6
            let cornerRadius: CGFloat = 12
            
            // Background
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: scanAreaWidth, height: scanAreaHeight)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
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
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }
}
