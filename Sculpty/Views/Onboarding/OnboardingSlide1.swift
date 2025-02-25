//
//  OnboardingSlide1.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/10/25.
//

import SwiftUI

struct OnboardingSlide1: View {
    @Binding var selectedTab: Int
    var lastTab: Int
    
    var body: some View {
        ZStack {
            ColorManager.background
                .ignoresSafeArea(edges: .all)
            
            VStack {
                Spacer()
                
                Text("Sculpty")
                    .font(.title)
                    .foregroundStyle(ColorManager.text)
                
                Text("Sculpt your perfect body.")
                    .font(.title2)
                    .foregroundStyle(ColorManager.text)
                
                Image("TransparentIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(.vertical, 25)
                
                Spacer()
                
                MoveSlideButton(selectedTab: $selectedTab, lastTab: lastTab)
            }
            .padding()
        }
    }
}

#Preview {
    Onboarding()
}
