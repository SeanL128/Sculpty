//
//  AppearanceMenuPopup.swift
//  Sculpty
//
//  Created by Sean Lindsay on 5/25/25.
//

import SwiftUI
import MijickPopups

struct AppearanceMenuPopup: CenterPopup {
    @Binding var selection: Appearance
    
    init(selection: Binding<Appearance>) {
        self._selection = selection
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Spacer()
                
                Text("Dark Mode")
                    .bodyText(size: 18, weight: .bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Appearance.displayOrder, id: \.id) { appearance in
                        Button {
                            selection = appearance
                            
                            Task {
                                await dismissLastPopup()
                            }
                        } label: {
                            HStack(alignment: .center) {
                                Text(appearance.rawValue)
                                    .bodyText(size: 16, weight: selection == appearance ? .bold : .regular)
                                    .textColor()
                                    .multilineTextAlignment(.leading)
                                
                                if selection == appearance {
                                    Spacer()
                                    
                                    Image(systemName: "checkmark")
                                        .padding(.horizontal, 8)
                                        .font(Font.system(size: 16))
                                }
                            }
                        }
                        .textColor()
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 5)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
    }
    
    func configurePopup(config: CenterPopupConfig) -> CenterPopupConfig {
        config
            .backgroundColor(ColorManager.background)
            .popupHorizontalPadding(24)
    }
}
