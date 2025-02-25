//
//  Onboarding.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/2/25.
//

import SwiftUI

struct Onboarding: View {
    @State var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            ColorManager.background
                .ignoresSafeArea(edges: .all)
            
            TabView (selection: $selectedTab) {
                OnboardingSlide1(selectedTab: $selectedTab, lastTab: 5)
                    .tag(0)
                
                OnboardingSlide2(selectedTab: $selectedTab, lastTab: 5)
                    .tag(1)
                
                OnboardingSlide3(selectedTab: $selectedTab, lastTab: 5)
                    .tag(2)
                
                OnboardingSlide4(selectedTab: $selectedTab, lastTab: 5)
                    .tag(3)
                
                OnboardingSlide5(selectedTab: $selectedTab, lastTab: 5)
                    .tag(4)
                
                OnboardingSlide6(selectedTab: $selectedTab, lastTab: 5)
                    .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}

#Preview {
    Onboarding()
}
