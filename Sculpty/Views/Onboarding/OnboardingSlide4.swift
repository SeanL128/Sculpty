//
//  OnboardingSlide4.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/10/25.
//

import SwiftUI

struct OnboardingSlide4: View {
    @Binding var selectedTab: Int
    var lastTab: Int
    
    var body: some View {
        ZStack {
            ColorManager.background
                .ignoresSafeArea(edges: .all)
            
            VStack {
                Spacer()
                
                Text("Log your body measurements")
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
