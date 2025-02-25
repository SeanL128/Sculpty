//
//  OnboardingSlide5.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/10/25.
//

import SwiftUI

struct OnboardingSlide5: View {
    @Binding var selectedTab: Int
    var lastTab: Int
    
    var body: some View {
        ZStack {
            ColorManager.background
                .ignoresSafeArea(edges: .all)
            
            VStack {
                Spacer()
                
                Text("View your progress at a glance")
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
