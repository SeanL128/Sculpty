//
//  Home.swift
//  Sculpty
//
//  Created by Sean Lindsay on 2/15/25.
//

import SwiftUI

struct Home: View {
    var body: some View {
        ContainerView(title: "Home", spacing: 16, showBackButton: false, trailingItems: {
            NavigationLink {
                Options()
            } label: {
                Image(systemName: "gear")
                    .padding(.horizontal, 5)
                    .font(Font.system(size: 20))
            }
            .textColor()
            .animatedButton()
        }) {
            // MARK: Workout Section
            HomeWorkoutSection()

            Spacer()
                .frame(height: 5)

            // MARK: Calories Section
            HomeCaloriesSection()

            Spacer()
                .frame(height: 5)

            // MARK: Measurement Section
            HomeMeasurementSection()
            
            Spacer()
                .frame(height: 5)
            
            // MARK: Insights Link
//            NavigationLink {
//                Insights()
//            } label: {
//                HStack(alignment: .center) {
//                    HStack(alignment: .center) {
//                        Spacer()
//                        
//                        Image(systemName: "chart.xyaxis.line")
//                            .font(Font.system(size: 18))
//                        
//                        Spacer()
//                    }
//                    .frame(width: 25)
//                    
//                    Text("INSIGHTS")
//                        .headingText(size: 24)
//                    
//                    Image(systemName: "chevron.right")
//                        .font(Font.system(size: 18))
//                        .padding(.leading, 4)
//                    
//                    Spacer()
//                }
//            }
//            .textColor()
//            .frame(maxWidth: .infinity)
            
            Spacer()
        }
    }
}
