//
//  OnboardingSlide3.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/10/25.
//

import SwiftUI

struct OnboardingSlide3: View {
    @Binding var selectedTab: Int
    var lastTab: Int
    
    var body: some View {
        ZStack {
            ColorManager.background
                .ignoresSafeArea(edges: .all)
            
            VStack {
                Spacer()
                
                Text("Count your calories")
                    .font(.title)
                    .foregroundStyle(ColorManager.text)
                
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
