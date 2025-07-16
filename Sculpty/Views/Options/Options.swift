//
//  Options.swift
//  Sculpty
//
//  Created by Sean Lindsay on 1/20/25.
//

import SwiftUI

struct Options: View {
    var body: some View {
        ContainerView(title: "Options", spacing: 24) {
            OptionsDefaultsSection()
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                ))

            Spacer()
                .frame(height: 5)
            
            OptionsCustomizationSection()
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                ))

            Spacer()
                .frame(height: 5)

            OptionsWorkoutsSection()
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .opacity
                ))

            Spacer()
                .frame(height: 5)

            OptionsCaloriesSection()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))

            Spacer()
                .frame(height: 5)

            OptionsStatsSection()
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .opacity
                ))

            Spacer()
                .frame(height: 5)

            OptionsNotificationsSection()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))

            Spacer()
                .frame(height: 5)

            OptionsDataSection()
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))

            Spacer()
                .frame(height: 5)

            OptionsMiscSection()
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                KeyboardDoneButton()
            }
        }
    }
}
